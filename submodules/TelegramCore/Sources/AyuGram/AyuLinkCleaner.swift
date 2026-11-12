// AyuGram: removes tracking parameters from links in outgoing messages.
//
// The strict mode and the per-site rules follow Link Cleaner by Corbin Davenport
// (https://github.com/corbindavenport/link-cleaner-js, MIT licence): everything after "?"
// is dropped except the parameters a site needs. The default mode is gentler and only
// drops parameters known to be trackers, so links to unknown sites keep working.

import Foundation

public final class AyuLinkCleaner {
    // Parameters that only identify a click, a share or a campaign, on any site.
    private static let trackingKeys: Set<String> = [
        "fbclid", "gclid", "gclsrc", "dclid", "gbraid", "wbraid", "msclkid", "yclid", "twclid", "ttclid",
        "li_fat_id", "igshid", "igsh", "mc_cid", "mc_eid", "_hsenc", "_hsmi", "hsctatracking", "mkt_tok",
        "oly_anon_id", "oly_enc_id", "vero_id", "vero_conv", "s_cid", "srsltid", "ref_src", "ref_url",
        "_ga", "_gl", "_openstat", "wickedid", "rb_clickid", "ml_subscriber", "ml_subscriber_hash",
        "__s", "cmpid", "share_id", "sharing_id", "xtor"
    ]

    private static let trackingPrefixes: [String] = ["utm_", "pk_", "mtm_", "stm_", "hsa_"]

    // Extra tracking parameters that are only safe to drop on these sites.
    private static let siteTrackingKeys: [(domain: String, keys: Set<String>)] = [
        (domain: "youtube.com", keys: ["si", "feature", "pp"]),
        (domain: "youtu.be", keys: ["si", "feature", "pp"]),
        (domain: "twitter.com", keys: ["s", "t"]),
        (domain: "x.com", keys: ["s", "t"]),
        (domain: "spotify.com", keys: ["si", "nd"]),
        (domain: "tiktok.com", keys: ["is_from_webapp", "sender_device", "_r", "_t", "is_copy_url", "share_app_id", "share_link_id", "social_sharing"]),
        (domain: "reddit.com", keys: ["ref", "ref_source", "rdt"]),
        (domain: "aliexpress.com", keys: ["spm", "scm", "aff_fcid", "aff_fsk", "aff_platform", "aff_trace_key", "algo_expid", "algo_pvid", "sk"]),
        (domain: "ebay.com", keys: ["mkcid", "mkrid", "mkevt", "campid", "toolid", "customid", "_trkparms", "_trksid", "hash"]),
        (domain: "linkedin.com", keys: ["trk", "trackingid", "refid", "lipi"]),
        (domain: "facebook.com", keys: ["mibextid", "rdid", "share_url", "__tn__", "__cft__[0]"]),
        (domain: "instagram.com", keys: ["img_index"])
    ]

    // Strict mode: the parameters each site needs. Everything else is dropped.
    private static func strictKeptKeys(host: String, path: String) -> Set<String> {
        var keys: Set<String> = ["q"]
        if host == "play.google.com" {
            keys.insert("id")
        } else if host == "www.macys.com" {
            keys.insert("ID")
        } else if hostMatches(host, "youtube.com") || host == "youtu.be" {
            keys.insert("v")
            keys.insert("t")
            if path.contains("playlist") {
                keys.insert("list")
            }
        } else if host == "www.facebook.com" && path.contains("story.php") {
            keys.insert("story_fbid")
            keys.insert("id")
        } else if host == "www.lenovo.com" {
            keys.insert("bundleId")
        } else if host == "www.xiaohongshu.com" {
            keys.insert("xsec_token")
        } else if host == "weatherkit.apple.com" {
            keys.insert("lang")
            keys.insert("party")
            keys.insert("ids")
        } else if host == "www.webtoons.com" {
            keys.insert("title_no")
            keys.insert("episode_no")
        } else if host == "www.reddit.com" && path.contains("media") {
            keys.insert("url")
        }
        return keys
    }

    private struct Parts {
        var origin: String
        var host: String
        var path: String
        var query: String?
        var fragment: String?
    }

    private static func hostMatches(_ host: String, _ domain: String) -> Bool {
        return host == domain || host.hasSuffix("." + domain)
    }

    private static func split(_ link: String) -> Parts? {
        guard let schemeRange = link.range(of: "://") else {
            return nil
        }
        let afterScheme = String(link[schemeRange.upperBound...])
        var authority = afterScheme
        var rest = ""
        if let index = afterScheme.firstIndex(where: { $0 == "/" || $0 == "?" || $0 == "#" }) {
            authority = String(afterScheme[..<index])
            rest = String(afterScheme[index...])
        }
        if authority.isEmpty {
            return nil
        }
        var host = authority.lowercased()
        if let at = host.lastIndex(of: "@") {
            host = String(host[host.index(after: at)...])
        }
        if let colon = host.firstIndex(of: ":") {
            host = String(host[..<colon])
        }
        var fragment: String?
        if let hash = rest.firstIndex(of: "#") {
            fragment = String(rest[rest.index(after: hash)...])
            rest = String(rest[..<hash])
        }
        var query: String?
        if let mark = rest.firstIndex(of: "?") {
            query = String(rest[rest.index(after: mark)...])
            rest = String(rest[..<mark])
        }
        let origin = String(link[..<schemeRange.upperBound]) + authority
        return Parts(origin: origin, host: host, path: rest, query: query, fragment: fragment)
    }

    private static func queryValue(_ query: String?, _ name: String) -> String? {
        guard let query = query else {
            return nil
        }
        for pair in query.components(separatedBy: "&") {
            guard let equals = pair.firstIndex(of: "=") else {
                continue
            }
            let key = String(pair[..<equals])
            if key == name {
                let value = String(pair[pair.index(after: equals)...])
                return value.removingPercentEncoding ?? value
            }
        }
        return nil
    }

    private static func filterQuery(_ query: String, keep: (String) -> Bool) -> String {
        var kept: [String] = []
        for pair in query.components(separatedBy: "&") {
            if pair.isEmpty {
                continue
            }
            var rawKey = pair
            if let equals = pair.firstIndex(of: "=") {
                rawKey = String(pair[..<equals])
            }
            let key = rawKey.removingPercentEncoding ?? rawKey
            if keep(key) {
                kept.append(pair)
            }
        }
        return kept.joined(separator: "&")
    }

    private static func firstCapture(_ pattern: String, in string: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }
        let nsString = string as NSString
        guard let match = regex.firstMatch(in: string, options: [], range: NSRange(location: 0, length: nsString.length)) else {
            return nil
        }
        if match.numberOfRanges < 2 {
            return nil
        }
        let range = match.range(at: 1)
        if range.location == NSNotFound || range.length == 0 {
            return nil
        }
        return nsString.substring(with: range)
    }

    // Links that only wrap another link.
    private static func unwrapRedirect(_ parts: Parts) -> String? {
        var target: String?
        if parts.host == "l.facebook.com" {
            target = queryValue(parts.query, "u")
        } else if parts.host == "www.google.com" && parts.path == "/url" {
            target = queryValue(parts.query, "url")
        } else if parts.host == "cts.businesswire.com" {
            target = queryValue(parts.query, "url")
        } else if parts.host == "href.li" {
            target = parts.query
        }
        guard let result = target else {
            return nil
        }
        let lower = result.lowercased()
        if lower.hasPrefix("http://") || lower.hasPrefix("https://") {
            return result
        }
        return nil
    }

    /// Returns the cleaned link, or nil when nothing needs to change.
    /// `strict` drops every parameter a site is not known to need, as Link Cleaner does.
    public static func clean(_ original: String, strict: Bool) -> String? {
        var link = original
        var addedScheme = false
        let lowerOriginal = original.lowercased()
        let hasWebScheme = lowerOriginal.hasPrefix("http://") || lowerOriginal.hasPrefix("https://")
        if !hasWebScheme {
            if original.contains("://") || lowerOriginal.hasPrefix("mailto:") || lowerOriginal.hasPrefix("tel:") {
                return nil
            }
            link = "https://" + original
            addedScheme = true
        }
        guard var parts = split(link) else {
            return nil
        }
        var changed = false
        if let unwrapped = unwrapRedirect(parts), let unwrappedParts = split(unwrapped) {
            parts = unwrappedParts
            addedScheme = false
            changed = true
        }
        let host = parts.host
        // Telegram's own links carry parameters that are part of the link.
        if hostMatches(host, "t.me") || hostMatches(host, "telegram.me") || hostMatches(host, "telegram.org") || hostMatches(host, "telegram.dog") {
            return nil
        }
        if let query = parts.query {
            let newQuery: String
            if strict {
                let keptKeys = strictKeptKeys(host: host, path: parts.path)
                newQuery = filterQuery(query, keep: { key in
                    return keptKeys.contains(key)
                })
            } else {
                var siteKeys = Set<String>()
                for entry in siteTrackingKeys {
                    if hostMatches(host, entry.domain) {
                        siteKeys.formUnion(entry.keys)
                    }
                }
                newQuery = filterQuery(query, keep: { key in
                    let lowerKey = key.lowercased()
                    if trackingKeys.contains(lowerKey) || siteKeys.contains(lowerKey) {
                        return false
                    }
                    for prefix in trackingPrefixes {
                        if lowerKey.hasPrefix(prefix) {
                            return false
                        }
                    }
                    return true
                })
            }
            if newQuery != query {
                changed = true
                parts.query = newQuery.isEmpty ? nil : newQuery
            }
        }
        if strict {
            if parts.fragment != nil {
                parts.fragment = nil
                changed = true
            }
            if hostMatches(host, "amazon.com") || host.hasPrefix("www.amazon.") {
                if let productId = firstCapture("(?:/dp/|/product/|/d/)(\\w+)", in: parts.path) {
                    let newPath = "/dp/" + productId
                    if newPath != parts.path {
                        parts.path = newPath
                        changed = true
                    }
                    if let wwwRange = parts.origin.range(of: "://www.") {
                        parts.origin = parts.origin.replacingCharacters(in: wwwRange, with: "://")
                        changed = true
                    }
                }
            } else if host == "www.walmart.com" {
                if let productId = firstCapture("/ip/.*/(\\d+)", in: parts.path) {
                    let newPath = "/ip/" + productId
                    if newPath != parts.path {
                        parts.path = newPath
                        changed = true
                    }
                }
            } else if host == "www.bestbuy.com" {
                if let productId = firstCapture("/(\\d+)\\.p", in: parts.path) {
                    let newPath = "/site/" + productId + ".p"
                    if newPath != parts.path {
                        parts.path = newPath
                        changed = true
                    }
                }
            }
        }
        if !changed {
            return nil
        }
        var result = parts.origin + parts.path
        if let query = parts.query {
            result += "?" + query
        }
        if let fragment = parts.fragment {
            result += "#" + fragment
        }
        if addedScheme && result.hasPrefix("https://") {
            result = String(result.dropFirst("https://".count))
        }
        if result == original {
            return nil
        }
        return result
    }

    /// Cleans every link in a message. Only text that the system link detector recognises as a
    /// web link is touched (the same detector Telegram uses, so bare "example.com/page" counts),
    /// plus the targets of hidden links. Entity ranges are UTF-16 offsets and are shifted to match.
    /// Returns nil when nothing changed.
    public static func cleanMessage(text: String, entities: [MessageTextEntity], strict: Bool) -> (text: String, entities: [MessageTextEntity])? {
        var entities = entities
        var changed = false

        for i in 0 ..< entities.count {
            if case let .TextUrl(url) = entities[i].type {
                if let cleaned = clean(url, strict: strict) {
                    entities[i].type = .TextUrl(url: cleaned)
                    changed = true
                }
            }
        }

        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            if changed {
                return (text: text, entities: entities)
            }
            return nil
        }
        let nsText = text as NSString
        let mutableText = NSMutableString(string: text)
        let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: nsText.length))
        for match in matches.reversed() {
            guard let url = match.url, let scheme = url.scheme?.lowercased() else {
                continue
            }
            if scheme != "http" && scheme != "https" {
                continue
            }
            let range = match.range
            let oldEnd = range.location + range.length
            var insideCode = false
            for entity in entities {
                switch entity.type {
                case .Code, .Pre:
                    if entity.range.lowerBound <= range.location && entity.range.upperBound >= oldEnd {
                        insideCode = true
                    }
                default:
                    break
                }
            }
            if insideCode {
                continue
            }
            let original = nsText.substring(with: range)
            guard let cleaned = clean(original, strict: strict) else {
                continue
            }
            let newLength = (cleaned as NSString).length
            let newEnd = range.location + newLength
            let delta = newLength - range.length
            mutableText.replaceCharacters(in: range, with: cleaned)
            for i in 0 ..< entities.count {
                var lower = entities[i].range.lowerBound
                var upper = entities[i].range.upperBound
                if lower >= oldEnd {
                    lower += delta
                } else if lower > range.location {
                    lower = min(lower, newEnd)
                }
                if upper >= oldEnd {
                    upper += delta
                } else if upper > range.location {
                    upper = min(upper, newEnd)
                }
                if upper < lower {
                    upper = lower
                }
                entities[i].range = lower ..< upper
            }
            changed = true
        }
        if !changed {
            return nil
        }
        let resultText = mutableText as String
        let resultEntities = entities.filter { !$0.range.isEmpty }
        return (text: resultText, entities: resultEntities)
    }
}
