import 'package:flutter/material.dart';
import 'package:localityconnector/userhomepage.dart';
import 'package:localityconnector/models/user.dart';
import 'package:localityconnector/models/business.dart';
import 'business.dart'; // Import for the BusinessDashboard class
import 'services/auth_service.dart';
import 'services/firestore_service.dart';

class SignInPage extends StatelessWidget {
  final bool isBusiness;

  const SignInPage({super.key, this.isBusiness = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade900,
              Colors.purple.shade900,
            ],
          ),
          image: DecorationImage(
            image: const NetworkImage(
                'https://static.vecteezy.com/system/resources/previews/008/680/961/non_2x/abstract-technology-background-free-vector.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    isBusiness ? "Business Login" : "User Login",
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const LoginContainer(title: 'User Login', isBusiness: false),
                  const SizedBox(height: 20),
                  const LoginContainer(
                      title: 'Business Login', isBusiness: true),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginContainer extends StatefulWidget {
  final String title;
  final bool isBusiness;

  const LoginContainer(
      {super.key, required this.title, required this.isBusiness});

  @override
  _LoginContainerState createState() => _LoginContainerState();
}

class _LoginContainerState extends State<LoginContainer> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService.instance;
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      if (widget.isBusiness) {
        // Try Firebase first for business login
        var businessFromFirestore =
            await _firestoreService.loginBusinessWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        // If not found in Firestore, try local database
        final business = businessFromFirestore ??
            await _authService.loginBusinessWithEmail(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );

        if (business != null) {
          // Navigate to business dashboard with business object
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BusinessDashboard(business: business)),
          );
          setState(() {
            _errorMessage = 'Invalid email or password';
          });
        }
      } else {
        // Try Firebase first for user login
        var userFromFirestore = await _firestoreService.loginUser(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        // If not found in Firestore, try local database
        final user = userFromFirestore ??
            await _authService.loginUser(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );

        if (user != null) {
          // Navigate to user homepage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserHomePage(user: user),
            ),
          );
        } else {
          setState(() {
            _errorMessage = 'Invalid email or password';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred during login: ${e.toString()}';
      });
      print('Login error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    if (widget.isBusiness) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Google Sign In is only available for users')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Create a hardcoded user with name "Ritik"
      final user = User(
        id: 1,
        username: 'Ritik',
        email: 'ritik@example.com',
        password: 'password',
        address: 'Pune, Maharashtra',
      );

      // Navigate directly to UserHomePage
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => UserHomePage(user: user),
        ),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again later.';
      });
      print('Google Sign In bypass error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithFacebook() async {
    if (widget.isBusiness) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Facebook Sign In is only available for users')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Create a hardcoded user with name "Ritik"
      final user = User(
        id: 1,
        username: 'Ritik',
        email: 'ritik@example.com',
        password: 'password',
        address: 'Pune, Maharashtra',
      );

      // Navigate directly to UserHomePage
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => UserHomePage(user: user),
        ),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again later.';
      });
      print('Facebook Sign In bypass error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: 350,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: widget.isBusiness ? 'Business Email' : 'Username',
              labelStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.7)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.7)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.orangeAccent),
              ),
              prefixIcon: const Icon(Icons.person, color: Colors.white70),
              fillColor: Colors.white.withOpacity(0.1),
              filled: true,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.7)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.7)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.orangeAccent),
              ),
              prefixIcon: const Icon(Icons.lock, color: Colors.white70),
              fillColor: Colors.white.withOpacity(0.1),
              filled: true,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            onPressed: _isLoading ? null : _login,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Login',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
          const SizedBox(height: 15),
          const Row(
            children: [
              Expanded(
                child: Divider(color: Colors.white54, thickness: 1),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('OR', style: TextStyle(color: Colors.white70)),
              ),
              Expanded(
                child: Divider(color: Colors.white54, thickness: 1),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              minimumSize: const Size(double.infinity, 45),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            icon: Image.asset(
              'assets/images/google.png',
              height: 24,
              width: 24,
              errorBuilder: (context, error, stackTrace) {
                return Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                  height: 24,
                  width: 24,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.login, color: Colors.red);
                  },
                );
              },
            ),
            label: const Text('Sign in with Google',
                style: TextStyle(fontSize: 14)),
            onPressed: widget.isBusiness
                ? () async {
                    setState(() {
                      _isLoading = true;
                    });
                    try {
                      // Create a hardcoded business for bypass
                      final business = Business(
                        id: 1,
                        businessName: 'Vishal General Store',
                        businessType: 'Retail',
                        businessDescription:
                            'A general store with various household items',
                        businessAddress: 'Pune, Maharashtra',
                        contactNumber: '9876543210',
                        email: 'vishal@example.com',
                        password: 'password',
                        latitude: 18.8209955,
                        longitude: 73.2694553,
                      );

                      // Navigate directly to BusinessDashboard
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BusinessDashboard(business: business),
                        ),
                        (route) => false,
                      );
                    } catch (e) {
                      print('Business Google SignIn bypass error: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'An error occurred. Please try again later.')),
                      );
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  }
                : _signInWithGoogle,
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1877F2),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 45),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            icon: Image.asset(
              'assets/images/facebook.png',
              height: 24,
              width: 24,
              errorBuilder: (context, error, stackTrace) {
                return Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Facebook_Logo_%282019%29.png/1200px-Facebook_Logo_%282019%29.png',
                  height: 24,
                  width: 24,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.login, color: Colors.white);
                  },
                );
              },
            ),
            label: const Text('Sign in with Facebook',
                style: TextStyle(fontSize: 14)),
            onPressed: widget.isBusiness
                ? () async {
                    setState(() {
                      _isLoading = true;
                    });
                    try {
                      // Create a hardcoded business for bypass
                      final business = Business(
                        id: 1,
                        businessName: 'Vishal General Store',
                        businessType: 'Retail',
                        businessDescription:
                            'A general store with various household items',
                        businessAddress: 'Pune, Maharashtra',
                        contactNumber: '9876543210',
                        email: 'vishal@example.com',
                        password: 'password',
                        latitude: 18.8209955,
                        longitude: 73.2694553,
                      );

                      // Navigate directly to BusinessDashboard
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BusinessDashboard(business: business),
                        ),
                        (route) => false,
                      );
                    } catch (e) {
                      print('Business Facebook SignIn bypass error: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'An error occurred. Please try again later.')),
                      );
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  }
                : _signInWithFacebook,
          ),
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
