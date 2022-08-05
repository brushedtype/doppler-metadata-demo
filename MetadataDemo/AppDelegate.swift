//
//  AppDelegate.swift
//  MetadataDemo
//
//  Created by Edward Wellbrook on 05/08/2022.
//

import Cocoa
import Combine
import DopplerExtendedAttributes

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    // =======================================================================================
    // A. Apps that only write the DopplerRefreshMetadataExtendedAttributeName should register
    //    an Apple Event handler in `applicationWillFinishLaunching`
    //    (note: this is *will* finishLaunching)
    //
    //    Doppler will only send the Apple event IFF a user selects this app for opening their
    //    files to edit
    // =======================================================================================
    func applicationWillFinishLaunching(_ notification: Notification) {

        // set event handler
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleDopplerEditMetadataEvent(_:with:)),
            forEventClass: DopplerEventClass,
            andEventID: DopplerEditMetadataEventId
        )

        // update the visual log
        AppDelegate.appendLog("evt handler registered")
    }

    // ====================================================================================================
    // B. Your normal `openFiles` handling should stay the same. There should be no need to make changes to
    //    acommodate Doppler here. It should Just Work™.
    // ====================================================================================================
    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        dispatchPrecondition(condition: .onQueue(.main))

        // update the visual log
        AppDelegate.appendLog("openFiles")
    }

    // ==================================================================================================================
    // C. Here is where you handle the Apple event. If you only write xattrs based on user preference, you should prompt
    //    the user to enable this preference here.
    //
    //    Doppler will send this event on EVERY request to openFiles. Therefore you should ignore showing a prompt if the
    //    user has already enabled the preference, or suppressed the prompt.
    //
    //    You should clearly explain the benefit for doing this to the user. You are encouraged to use the message below
    //    either verbatim, or as a base for writing your own message to the user.
    // ==================================================================================================================
    @objc func handleDopplerEditMetadataEvent(_ event: NSAppleEventDescriptor, with replyEvent: NSAppleEventDescriptor) {
        dispatchPrecondition(condition: .onQueue(.main))

        // check for doppler event
        guard event.eventClass == DopplerEventClass && event.eventID == DopplerEditMetadataEventId else {
            // update the visual log
            AppDelegate.appendLog("revd other evt")
            return
        }

        // update the visual log
        AppDelegate.appendLog("revd doppler edit meta evt")

        // check if setting already enabled
        guard AppDelegate.isDopplerXattrEnabled == false else {
            // update the visual log
            AppDelegate.appendLog("doppler preference already set, skipping prompt")
            return
        }

        // check for user ignores doppler prompts
        guard AppDelegate.isDopplerAlertsSuppressed == false else {
            // update the visual log
            AppDelegate.appendLog("doppler alerts supressed, skipping prompt")
            return
        }

        // configure alert
        let alert = NSAlert()
        alert.messageText = "Automatically show changes in Doppler?"
        alert.informativeText = """
        <APP NAME> can tell Doppler to automatically reload song and album information when you edit metadata.

        You can change this in <APP NAME> Settings at any time.
        """

        // support suppressing alerts
        alert.showsSuppressionButton = true
        alert.suppressionButton?.action = #selector(self.handleSupressDoplperAlert(_:))

        // add buttons
        alert.addButton(withTitle: "Update Info in Doppler")
        alert.addButton(withTitle: "Not Now")

        // show alert
        let result = alert.runModal()

        // store updated preference
        if result == .alertFirstButtonReturn {
            AppDelegate.isDopplerXattrEnabled = true

            // update the visual log
            AppDelegate.appendLog("user selected enable setting")

        } else {
            // update the visual log
            AppDelegate.appendLog("user selected not now")
        }
    }

    @objc func handleSupressDoplperAlert(_ sender: NSButton) {
        // in reality you would store this in user defaults or something that persists across app launches
        AppDelegate.isDopplerAlertsSuppressed = sender.state == .on
    }

    static var isDopplerAlertsSuppressed = false
    static var isDopplerXattrEnabled = false


    static var logs: CurrentValueSubject<[String], Never> = .init([])

    static func appendLog(_ str: String) {
        dispatchPrecondition(condition: .onQueue(.main))

        var logs: [String] = AppDelegate.logs.value
        logs.append("[\(Date())] " + str)

        AppDelegate.logs.send(logs)
    }
}

