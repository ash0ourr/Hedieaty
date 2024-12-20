import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project/views/login_page.dart';
import 'package:project/views/home_page.dart';
import 'package:project/views/create_event_page.dart';
import 'package:project/views/gift_list_page.dart';
import 'package:project/views/gift_details_page.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'End-to-End Test: Login, Search, Remove Search, Navigate to Create Event, and Fill Event Form',
        (WidgetTester tester) async {
      // Ensure Firebase is initialized before the test starts
      await Firebase.initializeApp();

      // Start the app by navigating to the LoginPage directly
      await tester.pumpWidget(MaterialApp(home: const LoginPage()));

      final emailField = find.byKey(const Key('emailField'));
      final passwordField = find.byKey(const Key('passwordField'));
      final loginButton = find.byKey(const Key('loginButton'));

      // Ensure the login fields are present
      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(loginButton, findsOneWidget);

      // Step 2: Enter the credentials
      await tester.enterText(emailField, 'ramzy@gmail.com');
      await tester.pumpAndSettle(); // Wait for the field to update
      await tester.enterText(passwordField, '123456');
      await tester.pumpAndSettle(); // Wait for the field to update

      // Step 3: Tap the login button and wait for the transition to the HomePage
      await tester.tap(loginButton);
      await tester.pumpAndSettle(); // Allow navigation and loading to complete

      // Ensure that we're on the HomePage after login
      expect(find.byType(HomePage), findsOneWidget);

      // Step 4: Perform a search for "Osama"
      final searchField = find.byKey(const Key('searchField'));
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'asdf');
      await tester.pumpAndSettle(); // Wait for the search results to update

      // Step 5: Remove the search query
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle(); // Wait for the list to update

      // Step 6: Tap on the "Create Event" button and wait for the navigation
      final createEventButton = find.byKey(const Key('eventButton'));
      expect(createEventButton, findsOneWidget);
      await tester.tap(createEventButton);
      await tester.pumpAndSettle(); // Wait for the navigation to CreateEventPage

      // Step 7: Ensure we're on the CreateEventPage
      expect(find.byType(CreateEventPage), findsOneWidget);

      // Step 8: Fill the Event Form
      final eventNameField = find.byKey(const Key('eventNameField'));
      final eventDescriptionField = find.byKey(const Key('eventDescriptionField'));
      final eventLocationField = find.byKey(const Key('eventLocationField'));

      // Ensure the form fields are present
      expect(eventNameField, findsOneWidget);
      expect(eventDescriptionField, findsOneWidget);
      expect(eventLocationField, findsOneWidget);

      // Step 9: Enter event details
      await tester.enterText(eventNameField, 'A Birthday Party');
      await tester.pumpAndSettle(); // Wait for the field to update
      await tester.enterText(eventDescriptionField, 'A fun birthday celebration!');
      await tester.pumpAndSettle(); // Wait for the field to update
      await tester.enterText(eventLocationField, '123 Party Street');
      await tester.pumpAndSettle(); // Wait for the field to update

      // Step 10: Tap on the "Select Date" button
      await tester.tap(find.text('Select Date'));
      await tester.pumpAndSettle(Duration(seconds: 2)); // Wait for the date picker to appear

      // Step 11: Select the 29th date
      final dateToPick = find.text('29');
      expect(dateToPick, findsOneWidget);
      await tester.tap(dateToPick);
      await tester.pumpAndSettle(); // Wait for the date to be selected

      // Step 12: Tap on the "OK" button in the date picker
      final okButton = find.text('OK');
      expect(okButton, findsOneWidget);
      await tester.tap(okButton);
      await tester.pumpAndSettle(); // Wait for the dialog to close

      // Step 13: Save the event
      final saveEventButton = find.text('Save Event');
      expect(saveEventButton, findsOneWidget);
      await tester.tap(saveEventButton);
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Find and tap on "My Events" navigation button
      final myEventsButton = find.text('My Events');
      expect(myEventsButton, findsOneWidget);
      await tester.tap(myEventsButton);
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Tap on the first event card
      final firstEventCard = find.byKey(const Key('event_card_1')); // Adjusted for new key
      expect(firstEventCard, findsOneWidget);
      await tester.tap(firstEventCard);
      await tester.pumpAndSettle();

      // Tap the "Add Gift" button
      final addGiftButton = find.byKey(const Key('add_gift_button'));
      expect(addGiftButton, findsOneWidget);
      await tester.tap(addGiftButton);
      await tester.pumpAndSettle();

      // **Gift Details Page: Fill Form**
      final giftNameField = find.byKey(const Key('gift_name_field'));
      final giftDescriptionField = find.byKey(const Key('gift_description_field'));
      final giftCategoryField = find.byKey(const Key('gift_category_field'));
      final giftPriceField = find.byKey(const Key('gift_price_field'));
      final saveGiftButton = find.byKey(const Key('save_gift_button'));

      // Ensure all gift form fields are present
      expect(giftNameField, findsOneWidget);
      expect(giftDescriptionField, findsOneWidget);
      expect(giftCategoryField, findsOneWidget);
      expect(giftPriceField, findsOneWidget);
      expect(saveGiftButton, findsOneWidget);

      // Fill the form fields
      await tester.enterText(giftNameField, 'Smartwatch');
      await tester.pumpAndSettle();
      await tester.enterText(giftDescriptionField, 'A trendy new smartwatch');
      await tester.pumpAndSettle();
      await tester.enterText(giftCategoryField, 'Electronics');
      await tester.pumpAndSettle();
      await tester.enterText(giftPriceField, '299.99');
      await tester.pumpAndSettle();

      // Save the gift
      await tester.tap(saveGiftButton);
      await tester.pumpAndSettle();

      // Assert that the success message is displayed
      expect(find.text('Gift saved successfully!'), findsOneWidget);

      // Wait for all asynchronous tasks to complete
      await tester.pumpAndSettle();
    },
  );
}
