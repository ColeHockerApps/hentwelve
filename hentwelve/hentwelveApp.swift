import SwiftUI
import Combine

@main
struct HenApp: App {

    @UIApplicationDelegateAdaptor(HenFlowDelegate.self) private var flow

    @StateObject private var router = HenRouter()
    @StateObject private var launch = HenLaunchStore()
    @StateObject private var session = HenSessionState()
    @StateObject private var orientation = HenOrientationManager()

    var body: some Scene {
        WindowGroup {
            HenEntryScreen()
                .environmentObject(router)
                .environmentObject(launch)
                .environmentObject(session)
                .environmentObject(orientation)
        }
    }
}
