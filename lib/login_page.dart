import 'package:flutter/material.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:travel_guide_app/NetworkHandler.dart';
import 'package:travel_guide_app/planning/planing_list.dart';
import 'package:travel_guide_app/success_login_page.dart';
import 'package:travel_guide_app/themes/colors.dart';
import 'package:travel_guide_app/utils/icon_name.dart';
import 'package:flutter_svg/svg.dart';
import 'components/border_button_widget.dart';
import 'components/custom_appbar.dart';
import 'components/custom_button_widget.dart';
import 'components/custom_textfield.dart';
import 'components/custom_textfield_password.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late GoogleSignIn _googleSignIn;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool _isSigningIn = false;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  int selectedRadio = 0;
  TextEditingController forgetEmailController = TextEditingController();
  NetworkHandler networkHandler = NetworkHandler();

  late String errorText;
  bool validate = false;
  bool circular = false;

  @override
  void initState() {
    super.initState();
    _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        // Add additional scopes here if needed
      ],
      clientId:
          '258473664377-jpcfl215149s6oqbatid26nvl5ro9a5s.apps.googleusercontent.com',
    );
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _isSigningIn = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() {
          _isSigningIn = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final User? user =
          (await _firebaseAuth.signInWithCredential(credential)).user;

      setState(() {
        _isSigningIn = false;
      });

      // Use the user object to authenticate the user in your app here
    } catch (error) {
      setState(() {
        _isSigningIn = false;
      });

      // Handle sign-in errors here
    }
  }

  void setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: _buildAppbar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSize _buildAppbar() {
    return const PreferredSize(
      preferredSize: Size.fromHeight(50),
      child: CustomAppBar(
        leftWidget: SizedBox(),
        color: Colors.transparent,
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 30),
      child: Form(
        child: Column(
          children: [
            SvgPicture.asset(
              'assets/images/Logo.svg',
              width: 100, // replace with your desired width
              height: 80, // replace with your desired height
              fit: BoxFit.cover,
            ),
            const SizedBox(
              height: 40,
            ),
            const Text(" Welcome to Zenify app!",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500)),
            const SizedBox(
              height: 50,
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _getEmailTextField(),
                  const SizedBox(
                    height: 15,
                  ),
                  _getPasswordTextField(),
                  const SizedBox(
                    height: 30,
                  ),
                  CustomButtonWidget(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        // TODO: Handle login button pressed
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PlanningListPage(),
                          ),
                        );
                      }
                    },
                    title: "Sign In",
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            _getForgetPassword(),
            const SizedBox(
              height: 50,
            ),
            _getTextOnLineDivider(),
            const SizedBox(
              height: 50,
            ),
            _getSocialMediaButton()
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return const SizedBox(
        height: 100,
        child: Center(
          child: Text.rich(TextSpan(children: [])),
        ));
  }

  Widget _getEmailTextField() {
    return CustomTextField(
      controller: emailController,
      prefixIcon: const Icon(
        Icons.email,
        size: 18,
      ),
      labelText: "Email",
      validator: (value) {
        if (value == null || value.isEmpty || !value.contains('@')) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _getPasswordTextField() {
    return CustomTextFieldPassword(
      controller: passwordController,
      validator: (value) {
        if (value == null || value.isEmpty || value.length < 8) {
          return 'Password must be at least 8 characters long';
        }
        return null;
      },
    );
  }

  Widget _getForgetPassword() {
    return GestureDetector(
      onTap: () {},
      child: Container(),
    );
  }

  Widget _getTextOnLineDivider() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Divider(color: lineBorderColor, thickness: 1),
        Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          color: white,
          child: const Text("Or Login With"),
        )
      ],
    );
  }

  Widget _getSocialMediaButton() {
    return _isSigningIn
        ? const CircularProgressIndicator()
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BorderButtonV2(
                preIcon: IconName.facebook,
                iconSize: 22,
                onTap: () {
                  _facebookLogin();
                },
              ),
              const SizedBox(
                width: 20,
              ),
              BorderButtonV2(
                preIcon: IconName.google,
                iconSize: 22,
                onTap: _handleSignIn,
              ),
              const SizedBox(
                width: 20,
              ),
              BorderButtonV2(
                preIcon: IconName.apple,
                iconSize: 22,
                onTap: () {},
              )
            ],
          );
  }

  _facebookLogin() async {
    // Create an instance of FacebookLogin
    final fb = FacebookLogin();
    // Log in
    final res = await fb.logIn(permissions: [
      FacebookPermission.publicProfile, // permission to get public profile
      FacebookPermission.email, // permission to get email address
    ]);
    // Check result status
    switch (res.status) {
      case FacebookLoginStatus.success:
        final FacebookAccessToken? accessToken =
            res.accessToken; // get accessToken for auth login
        final profile = await fb.getUserProfile(); // get profile of user
        final imageUrl =
            await fb.getProfileImageUrl(width: 100); // get user profile image
        final email = await fb.getUserEmail(); // get user's email address

        print('Access token: ${accessToken?.token}');
        print('Hello, ${profile!.name}! You ID: ${profile.userId}');
        print('Your profile image: $imageUrl');
        if (email != null) print('And your email is $email');

        //push to success page after successfully signed in
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: ((context) => SuccessLoginPage(
                      fbAccessToken: accessToken!.token,
                      profileImage: imageUrl!,
                      fbName: profile.name!,
                      fbId: profile.userId,
                      fbEmail: email!,
                    ))));

        break;
      case FacebookLoginStatus.cancel:
        // User cancel log in
        break;
      case FacebookLoginStatus.error:
        // Log in failed
        print('Error while log in: ${res.error}');
        break;
    }
  }
}
