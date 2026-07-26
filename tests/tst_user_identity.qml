import QtQuick
import QtTest
import "../stores/system/UserIdentity.js" as UserIdentity

TestCase {
    name: "UserIdentity"

    function test_parsesBusctlValues() {
        compare(
            UserIdentity.busctlValue(
                "o \"/org/freedesktop/Accounts/User1000\""
            ),
            "/org/freedesktop/Accounts/User1000"
        )
        compare(
            UserIdentity.busctlValue("s \"Maylton Fernandes\""),
            "Maylton Fernandes"
        )
    }

    function test_buildsReadableInitials() {
        compare(
            UserIdentity.initials("Maylton Fernandes", "maylton"),
            "MF"
        )
        compare(UserIdentity.initials("", "maylton"), "M")
        compare(UserIdentity.initials("", ""), "")
    }

    function test_avatarPriorityAndDeduplication() {
        const candidates = UserIdentity.avatarCandidates(
            "/home/user/.face",
            "/home/user",
            "file:///tmp/custom.png"
        )

        compare(candidates.length, 3)
        compare(candidates[0], "/home/user/.face")
        compare(candidates[1], "/home/user/.face.icon")
        compare(candidates[2], "file:///tmp/custom.png")
    }

    function test_convertsOnlyLocalPathsToUrls() {
        compare(
            UserIdentity.sourceUrl("/home/user/My Face.png"),
            "file:///home/user/My%20Face.png"
        )
        compare(
            UserIdentity.sourceUrl("file:///tmp/avatar.png"),
            "file:///tmp/avatar.png"
        )
    }
}
