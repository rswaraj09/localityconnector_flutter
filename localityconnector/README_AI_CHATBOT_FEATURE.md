# Locality Connector AI Chatbot Feature

## Business Lookup with Map Integration

This feature enables users to quickly find business information through the AI Chatbot by clicking category buttons. When clicking on "Restaurants" or "Pharmacies" buttons, the chatbot will display matching businesses from the database, including:

- Business Name
- Business Address
- Longitude and Latitude coordinates
- "Locate on Map" button

**Note: Only businesses with valid longitude and latitude coordinates will be displayed in the results, and results are filtered by their specific categories.**

### How It Works

1. **Quick Access Buttons**: The chatbot interface displays quick access buttons for "Restaurants", "Pharmacies", "Grocery", and "Show all businesses".

2. **Category-Specific Filtering**: When a button is clicked, the system:
   - Queries the SQLite database for businesses in that category
   - Filters results to show ONLY businesses of the selected category
   - Only shows businesses with valid coordinates
   - Formats the information for display

3. **Map Integration**: Each business listing includes a "Locate on Map" button that:
   - Opens a map view with the business location pinned
   - Uses Google Maps integration to show the exact location
   - Displays the business name and address in the map marker

4. **Category Matching Logic**:
   - Businesses are matched to categories based on both category ID and business type fields
   - For Restaurants: matches "restaurant", "food", "cafe", "diner", "canteen", "dining" or category ID 3
   - For Pharmacies: matches "pharmacy", "drug", "health", "medicine" or category ID 2 
   - For Grocery: matches "grocery", "supermarket", "market" or category ID 1

5. **Fallback Mechanism**: If no businesses are found in the database for a specific category:
   - The system will try searching within the existing business list
   - If still empty, it will load all businesses from the database as a fallback
   - All businesses without coordinates are filtered out from results

### Technical Implementation

- The feature leverages the existing `DatabaseHelper` class to query businesses by category
- Businesses are filtered to only include those with valid coordinate data and matching the selected category
- Business results are displayed with coordinates to enable map functionality 
- The Google Maps integration shows the exact location of the business
- The feature handles edge cases like missing coordinate data by simply not showing those businesses

### Example Usage

1. Open the AI Chatbot screen
2. Click on "Restaurants" or "Pharmacies" button
3. View the list of businesses with their details (only matching businesses with coordinates)
4. Click "Locate on Map" to see the business location on a map

This feature provides a seamless way for users to find and locate local businesses through the AI chatbot interface. 