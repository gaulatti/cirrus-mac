import SwiftUI

//
//  Timeline.swift
//  mac
//
//  Created by Javier Godoy Núñez on 2/22/25.
//

func convertAtUriToWebUrl(_ uri: String) -> URL? {
      let components = uri.split(separator: "/")
      guard components.count >= 4,
            components[0] == "at:",
            components[2] == "app.bsky.feed.post"
      else { return nil }

      let did = components[1]
      let postId = components[3]
      let urlString = "https://bsky.app/profile/\(did)/post/\(postId)"

      return URL(string: urlString)
}
