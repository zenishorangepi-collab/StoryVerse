import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:utsav_interview/app/login_view/login_controller.dart';
import 'package:utsav_interview/core/common_color.dart';
import 'package:utsav_interview/core/common_function.dart';
import 'package:utsav_interview/core/common_string.dart';
import 'package:utsav_interview/core/common_style.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(
      init: LoginController(),
      builder: (controller) {
        return Form(
          key: controller.formKey,
          child: SafeArea(
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: AppColors.colorWhite), onPressed: () => Navigator.pop(context)),
                elevation: 0,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.black,
              ),
              body: SingleChildScrollView(
                child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        // Title
                        Text(CS.vLoginWithEmail, style: AppTextStyles.heading2),
                        const SizedBox(height: 30),

                        // Email label
                        Text(CS.vEmail, style: AppTextStyles.bodyLarge16white500),
                        const SizedBox(height: 8),

                        // Email textfield
                        TextFormField(
                          // controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: AppColors.colorWhite,
                          style: AppTextStyles.bodyLarge16white500,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 10),
                            hintText: CS.vEnterYourEmail,
                            border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.colorWhite)),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.colorWhite)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return CS.vEmailIsRequired;
                            }

                            final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

                            if (!emailRegex.hasMatch(value.trim())) {
                              return CS.vEnterValidEmail;
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Password label
                        Text(CS.vPassword, style: AppTextStyles.bodyLarge16white500),
                        const SizedBox(height: 8),

                        // Password textfield
                        TextFormField(
                          controller: controller.passwordController,
                          obscureText: controller.obscurePassword,
                          cursorColor: AppColors.colorWhite,
                          style: AppTextStyles.bodyLarge16white500,
                          decoration: InputDecoration(
                            hintText: CS.vEnterYourPassword,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10),
                            border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.colorWhite)),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.colorWhite)),
                            suffixIcon: IconButton(
                              icon: Icon(!controller.obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.colorWhite),
                              onPressed: () {
                                controller.obscurePassword = !controller.obscurePassword;
                                controller.update();
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return CS.vPasswordRequired;
                            }
                            return null;
                          },
                        ),
                      ],
                    ).screenPadding(),
              ),
              bottomNavigationBar: AnimatedPadding(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child:
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              side: const BorderSide(color: Colors.black12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              if (controller.formKey.currentState!.validate()) {}
                            },
                            child: Text(CS.vLogin, style: AppTextStyles.buttonTextBlack18),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Forgot password
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () {
                              // TODO: Forgot password action
                            },
                            child: Text(CS.vForgotPassword, style: AppTextStyles.bodyLarge),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ).screenPadding(),
              ),
            ),
          ),
        );
      },
    );
  }
}
