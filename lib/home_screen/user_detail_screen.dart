import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:baat_cheet/common/widgets/hms_listenable_button.dart';
import 'package:baat_cheet/common/util/app_color.dart';
import 'package:baat_cheet/common/util/utility_function.dart';
import 'package:baat_cheet/meeting/meeting_store.dart';
import 'package:baat_cheet/enum/meeting_flow.dart';
import 'package:baat_cheet/hms_sdk_interactor.dart';
import 'package:baat_cheet/home_screen/screen_controller.dart';
import 'package:baat_cheet/preview/preview_page.dart';
import 'package:baat_cheet/preview/preview_store.dart';
import 'package:provider/provider.dart';

import '../common/bottom_sheets/app_settings_bottom_sheet.dart';

class UserDetailScreen extends StatefulWidget {
  // final String meetingLink;
  final MeetingFlow meetingFlow;
  final bool autofocusField;

  const UserDetailScreen(
      {super.key, required this.meetingFlow, this.autofocusField = false});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  var myToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhY2Nlc3Nfa2V5IjoiNjNmNzE3ODY2N2RjZjgwM2JkYjYzMmQ3Iiwicm9vbV9pZCI6IjYzZmYxNWFkMDQ5ZTJjMjVmZDIzMmQ1OSIsInVzZXJfaWQiOiJlbXp4ZXFucCIsInJvbGUiOiJob3N0IiwianRpIjoiMzI0MjJiZWItODllNy00ZWY1LWI4NmQtYTgwMTgwZDdmNTcwIiwidHlwZSI6ImFwcCIsInZlcnNpb24iOjIsImV4cCI6MTY3NzgyODM5N30.O235QxNaoa3XvkLXsuqHB1hSUkiXVzN58mGLVvGdpAw";

  TextEditingController nameController = TextEditingController();
  TextEditingController roomTokenController = TextEditingController();
  late PreviewStore _previewStore;
  late MeetingStore _meetingStore;
  late HMSSDKInteractor _hmsSDKInteractor;

  @override
  void initState() {
    super.initState();
    loadData();
    roomTokenController = TextEditingController(text: myToken);
  }

  Future<void> setHMSSDKInteractor(
      {required bool joinWithMutedAudio,
      required bool joinWithMutedVideo,
      required bool isSoftwareDecoderDisabled,
      required bool isAudioMixerDisabled}) async {
    HMSIOSScreenshareConfig iOSScreenshareConfig = HMSIOSScreenshareConfig(
        appGroup: "group.flutterhms",
        preferredExtension:
            "live.100ms.flutter.FlutterBroadcastUploadExtension");

    _hmsSDKInteractor = HMSSDKInteractor(
        iOSScreenshareConfig: iOSScreenshareConfig,
        joinWithMutedAudio: joinWithMutedAudio,
        joinWithMutedVideo: joinWithMutedVideo,
        isSoftwareDecoderDisabled: isSoftwareDecoderDisabled,
        isAudioMixerDisabled: isAudioMixerDisabled);
    //build call should be a blocking call
    await _hmsSDKInteractor.build();
  }

  void loadData() async {
    nameController.text = await Utilities.getStringData(key: "name");
    nameController.selection = TextSelection.fromPosition(
        TextPosition(offset: nameController.text.length));
    setState(() {});
  }

  void showPreview(bool res) async {
    if (nameController.text.isEmpty) {
      Utilities.showToast("Please enter you name");
    } else {
      Utilities.saveStringData(key: "name", value: nameController.text.trim());
      res = await Utilities.getPermissions();
      bool skipPreview =
          await Utilities.getBoolData(key: 'skip-preview') ?? false;
      bool joinWithMutedAudio =
          await Utilities.getBoolData(key: 'join-with-muted-audio') ?? true;
      bool joinWithMutedVideo =
          await Utilities.getBoolData(key: 'join-with-muted-video') ?? true;
      bool isSoftwareDecoderDisabled =
          await Utilities.getBoolData(key: 'software-decoder-disabled') ?? true;
      bool isAudioMixerDisabled =
          await Utilities.getBoolData(key: 'audio-mixer-disabled') ?? true;
      if (res) {
        await setHMSSDKInteractor(
            joinWithMutedAudio: joinWithMutedAudio,
            joinWithMutedVideo: joinWithMutedVideo,
            isSoftwareDecoderDisabled: isSoftwareDecoderDisabled,
            isAudioMixerDisabled: isAudioMixerDisabled);

        if (!skipPreview) {
          _previewStore = PreviewStore(hmsSDKInteractor: _hmsSDKInteractor);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ListenableProvider.value(
                    value: _previewStore,
                    child: PreviewPage(
                      roomToken: roomTokenController.text,
                      meetingFlow: widget.meetingFlow,
                      name: nameController.text,
                    ),
                  )));
        } else {
          bool showStats =
              await Utilities.getBoolData(key: 'show-stats') ?? false;
          bool mirrorCamera =
              await Utilities.getBoolData(key: 'mirror-camera') ?? false;
          _meetingStore = MeetingStore(hmsSDKInteractor: _hmsSDKInteractor);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ListenableProvider.value(
                    value: _meetingStore,
                    child: ScreenController(
                      isRoomMute: false,
                      isStreamingLink: widget.meetingFlow == MeetingFlow.meeting
                          ? false
                          : true,
                      localPeerNetworkQuality: -1,
                      user: nameController.text.trim(),
                      mirrorCamera: mirrorCamera,
                      showStats: showStats,
                      roomToken: roomTokenController.text,
                    ),
                  )));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool res = false;
    return Scaffold(
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/user-music.svg',
              width: width / 4,
            ),
            const SizedBox(
              height: 40,
            ),
            Text("Go live in five!",
                style: GoogleFonts.inter(
                    color: themeDefaultColor,
                    fontSize: 34,
                    fontWeight: FontWeight.w600)),
            const SizedBox(
              height: 4,
            ),
            Text("Let's get started with your name",
                style: GoogleFonts.inter(
                    color: themeSubHeadingColor,
                    height: 1.5,
                    fontSize: 16,
                    fontWeight: FontWeight.w400)),
            const SizedBox(
              height: 40,
            ),
            SizedBox(
              width: width * 0.95,
              child: TextField(
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  showPreview(res);
                },
                autofocus: widget.autofocusField,
                textCapitalization: TextCapitalization.words,
                style: GoogleFonts.inter(),
                controller: nameController,
                keyboardType: TextInputType.name,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                    suffixIcon: nameController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              nameController.text = "";
                              setState(() {});
                            },
                            icon: const Icon(Icons.clear),
                          ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    fillColor: themeSurfaceColor,
                    filled: true,
                    hintText: 'Enter your name here',
                    hintStyle: GoogleFonts.inter(
                        color: themeHintColor,
                        height: 1.5,
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: borderColor, width: 1),
                        borderRadius: const BorderRadius.all(Radius.circular(8))),
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)))),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: width * 0.95,
              child: TextField(
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  showPreview(res);
                },
                autofocus: widget.autofocusField,
                textCapitalization: TextCapitalization.words,
                style: GoogleFonts.inter(),
                controller: roomTokenController,
                keyboardType: TextInputType.visiblePassword,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                    suffixIcon: nameController.text.isEmpty
                        ? null
                        : IconButton(
                      onPressed: () {
                        roomTokenController.text = "";
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear),
                    ),
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    fillColor: themeSurfaceColor,
                    filled: true,
                    hintText: 'Enter room token',
                    hintStyle: GoogleFonts.inter(
                        color: themeHintColor,
                        height: 1.5,
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: borderColor, width: 1),
                        borderRadius: const BorderRadius.all(Radius.circular(8))),
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)))),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            HMSListenableButton(
                width: width * 0.5,
                onPressed: () async => {
                      FocusManager.instance.primaryFocus?.unfocus(),
                      showPreview(res),
                    },
                childWidget: Container(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Get Started',
                          style: GoogleFonts.inter(
                              color: nameController.text.isEmpty
                                  ? themeDisabledTextColor
                                  : enabledTextColor,
                              height: 1,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(
                        width: 4,
                      ),
                      Align(
                        child: showDialogA(),
                        alignment: Alignment.centerRight,
                      )
                    ],
                  ),
                ),
                textController: nameController,
                errorMessage: "Please enter you name")
          ],
        ),
      )),
    );
  }

  showDialogA() {
    return GestureDetector(
      onTap: (() => showModalBottomSheet(
          isScrollControlled: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          context: context,
          builder: (ctx) => AppSettingsBottomSheet(
                appVersion: "9.0",
                // appVersion: _packageInfo.version +
                //     " (${_packageInfo.buildNumber})",
              ))),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8),
        child: SvgPicture.asset(
          "assets/icons/more.svg",
          color: themeDisabledTextColor,
          // color: meetingLinkController.text.isEmpty
          //     ? themeDisabledTextColor
          //     : hmsWhiteColor,
          fit: BoxFit.scaleDown,
        ),
      ),
    );
  }
}
