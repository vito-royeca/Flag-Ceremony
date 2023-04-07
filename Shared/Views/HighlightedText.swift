//
//  HighlightedText.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 4/7/23.
//

import SwiftUI

struct HighlightedText: View {
    let text: String
    let matching: String
    let highlightColor: Color
    let strictPrefix: Bool

    init(_ text: String, matching: String, highlightColor: Color = .systemBlue, strictPrefix: Bool = true) {
        self.text = text
        self.matching = matching
        self.highlightColor = highlightColor
        self.strictPrefix = strictPrefix
    }
    
    var body: some View {
        guard  let regex = try? NSRegularExpression(pattern: NSRegularExpression.escapedPattern(for: matching).trimmingCharacters(in: .whitespacesAndNewlines).folding(options: .regularExpression, locale: .current),
                                                    options: .caseInsensitive) else {
            return Text(text)
        }

        let length = strictPrefix ? (matching.count == 1 ? 1 : text.count) : text.count
        let range = NSRange(location: 0, length: length)
        let matches = regex.matches(in: text, options: .withTransparentBounds, range: range)

        return text.enumerated().map { (char) -> Text in
            guard matches.filter( {
                $0.range.contains(char.offset)
            }).count == 0 else {
                return Text( String(char.element) ).foregroundColor(highlightColor)
            }
            return Text( String(char.element) )

        }.reduce(Text("")) { (a, b) -> Text in
            return (a + b)
        }
    }
}

struct HighlightedText_Previews: PreviewProvider {
    static var previews: some View {
        HighlightedText("Flag Ceremony", matching: "ceremony", strictPrefix: false)
    }
}
