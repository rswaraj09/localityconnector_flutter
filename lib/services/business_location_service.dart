            } else if (categoryName == 'Restaurant') {
              matchesCategory = businessTypeLower.contains('restaurant') ||
                  businessTypeLower.contains('cafe') ||
                  businessTypeLower.contains('dining') ||
                  categoryId == 3;
              
              // Exclude Vimeet Canteen from Restaurant category
              if (data['business_name'] == "Vimeet Canteen") {
                matchesCategory = false;
              } 

      // Add hardcoded grocery stores when Grocery category is selected
      if (categoryName == 'Grocery') {
        // Check if hardcoded businesses already exist in the list
        bool vishalGeneralStoreExists = businesses
            .any((business) => business.businessName == "Vishal General Store");

        bool lottaGeneralStoreExists = businesses
            .any((business) => business.businessName == "Lotta General Store");

        bool aniketKiranaExists = businesses
            .any((business) => business.businessName == "Aniket Kirana");

        bool hariNamKiranaExists = businesses
            .any((business) => business.businessName == "HariNam Kirana");

        // Add Vishal General Store if not exists
        if (!vishalGeneralStoreExists) {
          businesses.add(Business(
              id: 9,
              businessName: "Vishal General Store",
              businessType: "Grocery",
              businessDescription:
                  "General grocery store with daily necessities",
              businessAddress: "Dhamini, Khalapur, Raigad, Maharashtra",
              contactNumber: "",
              email: "vishalstore@gmail.com",
              password: "123456",
              longitude: 73.27575712390647,
              latitude: 18.817036731846635,
              categoryId: 1,
              averageRating: null,
              totalReviews: null,
              distance: 0.1));
        }

        // Add Lotta General Store if not exists
        if (!lottaGeneralStoreExists) {
          businesses.add(Business(
              id: 10,
              businessName: "Lotta General Store",
              businessType: "Grocery",
              businessDescription:
                  "Local grocery shop serving the neighborhood",
              businessAddress: "Dhamini, Khalapur, Maharashtra",
              contactNumber: "",
              email: "lottastore@gmail.com",
              password: "123456",
              longitude: 73.27500964972695,
              latitude: 18.81763470287621,
              categoryId: 1,
              averageRating: null,
              totalReviews: null,
              distance: 0.15));
        }

        // Add Aniket Kirana if not exists
        if (!aniketKiranaExists) {
          businesses.add(Business(
              id: 11,
              businessName: "Aniket Kirana",
              businessType: "Grocery",
              businessDescription:
                  "Family-owned grocery store with fresh produce",
              businessAddress: "Dhamini, Khalapur, Maharashtra",
              contactNumber: "",
              email: "aniketkirana@gmail.com",
              password: "123456",
              longitude: 73.27544366699958,
              latitude: 18.81717823664992,
              categoryId: 1,
              averageRating: null,
              totalReviews: null,
              distance: 0.18));
        }

        // Add HariNam Kirana if not exists
        if (!hariNamKiranaExists) {
          businesses.add(Business(
              id: 12,
              businessName: "HariNam Kirana",
              businessType: "Grocery",
              businessDescription:
                  "Traditional grocery store with wide selection",
              businessAddress: "Khumbhivali, Maharashtra",
              contactNumber: "",
              email: "harinamkirana@gmail.com",
              password: "123456",
              longitude: 73.26146824521275,
              latitude: 18.82281217056494,
              categoryId: 1,
              averageRating: null,
              totalReviews: null,
              distance: 0.25));
        }

        // Re-sort after adding hardcoded businesses
        businesses.sort((a, b) {
          final distanceA = a.distance ?? double.infinity;
          final distanceB = b.distance ?? double.infinity;
          return distanceA.compareTo(distanceB);
        });
      }
      
      // Add hardcoded pharmacy stores when Pharmacy category is selected
      if (categoryName == 'Pharmacy') {
        // Check if hardcoded businesses already exist in the list
        bool metroMedicalExists = businesses
            .any((business) => business.businessName == "Metro Medical");

        bool khumbhivaliMedicalExists = businesses
            .any((business) => business.businessName == "Khumbhivali Medical Shop");

        // Add Metro Medical if not exists
        if (!metroMedicalExists) {
          businesses.add(Business(
              id: 15,
              businessName: "Metro Medical",
              businessType: "Pharmacy",
              businessDescription:
                  "Modern pharmacy offering a wide range of medicines and healthcare products",
              businessAddress: "Dhamini, Khalapur, Maharashtra",
              contactNumber: "",
              email: "metromedical@gmail.com",
              password: "123456",
              longitude: 73.27559385321833,
              latitude: 18.816934811518898,
              categoryId: 2,
              averageRating: null,
              totalReviews: null,
              distance: 0.22));
        }

        // Add Khumbhivali Medical Shop if not exists
        if (!khumbhivaliMedicalExists) {
          businesses.add(Business(
              id: 16,
              businessName: "Khumbhivali Medical Shop",
              businessType: "Pharmacy",
              businessDescription:
                  "Local pharmacy providing essential medications and health supplies",
              businessAddress: "Khumbhivali, Maharashtra",
              contactNumber: "",
              email: "khumbhivalimed@gmail.com",
              password: "123456",
              longitude: 73.26211099260537,
              latitude: 18.822873137516815,
              categoryId: 2,
              averageRating: null,
              totalReviews: null,
              distance: 0.35));
        }

        // Re-sort after adding hardcoded businesses
        businesses.sort((a, b) {
          final distanceA = a.distance ?? double.infinity;
          final distanceB = b.distance ?? double.infinity;
          return distanceA.compareTo(distanceB);
        });
      } 