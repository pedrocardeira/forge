import SwiftUI

enum ForgeTheme { static let accent = Color.orange; static let background = Color(.systemGroupedBackground); static let card = Color(.secondarySystemGroupedBackground); static let soft = Color.orange.opacity(0.12) }
struct PrimaryButton: View { var title:String; var icon:String?=nil; var action:()->Void; var body: some View { Button(action:action){ HStack{ if let icon { Image(systemName:icon) }; Text(title).fontWeight(.heavy) }.frame(maxWidth:.infinity).padding(.vertical,15).background(ForgeTheme.accent).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius:20, style:.continuous)) } } }
struct Card<Content:View>: View { @ViewBuilder var content:Content; var body: some View { content.padding(16).background(ForgeTheme.card).clipShape(RoundedRectangle(cornerRadius:24, style:.continuous)) } }
