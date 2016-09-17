ipa-packager
===

This script packages a signed application into an IPA that contains the SwiftSupport folder with libswiftCore*.dylib.
This is needed to deploy an app made with Swift into the AppStore

#Usage

###For Swift 3 run the script:
	sh package_ipa_default.sh /path/to/signed/app /output/ipa/path


###For Swift 2.3 run the script:
	sh package_ipa_xcode8_swift23.sh /path/to/signed/app /output/ipa/path


###Requirements
- Xcode 8
- Xcode command line tools

###License
This script is distributed in terms of LGPL license. See http://www.gnu.org/licenses/lgpl.html for more details.
