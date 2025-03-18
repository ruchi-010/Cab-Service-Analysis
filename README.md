# Cab Service Analysis
![Trip Summary Report](Images/report_trips.jpg)                  ![Passenger Summmary Report](Images/report_passengers.jpg)             

# Project Overview
- The ride-hailing industry is witnessing a rapid transformation, driven by increasing urbanization, evolving consumer preferences, and intensified competition. **Good Cabs**, operating in multiple tier-2 cities, is at a critical juncture where optimizing business operations and improving service quality are pivotal to sustaining long-term growth. While expanding market reach is crucial, ensuring high levels of customer satisfaction and operational efficiency is equally vital to maintain a competitive edge.

- To remain profitable, the company must address key operational and business challenges:

   - **Fluctuating Demand Patterns:** Understanding how trip demand varies by city, time of day, and customer segment is essential for better resource allocation.
   - **Customer Retention vs. Acquisition:** Acquiring new passengers is costly, making repeat customer retention a more sustainable growth strategy. Analyzing repeat ride trends helps identify loyalty drivers.
   - **Revenue Maximization:** Fare optimization and ride frequency play a crucial role in increasing revenue. The project explores the correlation between trip frequency, fare structures, and total revenue generation.
   - **Performance vs. Strategic Targets:** Good Cabs sets operational and financial benchmarks, such as total trip targets and passenger acquisition goals. This project evaluates actual performance against these goals, identifying gaps and improvement areas.
     
- Through in-depth data analysis, this project uncovers actionable insights that will guide strategic decision-making, allowing Good Cabs to refine its operational approach, enhance financial planning, and improve overall service delivery.

# Data Description

This project processes 426,885 records spanning trip data, customer behavior, and business performance metrics to provide a comprehensive analytical foundation for Good Cabs' operations. The datasets are categorized into two key domains: Operational Trip Data and Business Targets, each facilitating strategic decision-making and service optimization.

1. Operational Trip Data ``trips_db``
 - This dataset offers a granular view of Good Cabs' ride activity, providing the foundation for demand forecasting, service efficiency, and customer segmentation.

  - Geographic Reference `dim_city` – Defines city identifiers and names for location-based analysis.
  - Time-Series Data `dim_date` – Structures ride records across time dimensions, distinguishing between weekdays and weekends to analyze demand fluctuations.
  - Ride Transactions `fact_trips` – Contains detailed trip-level data, including fare amounts, trip distances, and passenger/driver ratings, supporting financial and operational insights.
   - Customer Segmentation `fact_passenger_summary` – Aggregates passenger counts by city and month, enabling retention trend analysis and service personalization.
   - Repeat Rider Behavior `dim_repeat_trip_distribution` – Captures frequency-based ride patterns, identifying engagement levels among returning customers.
     
2. Business Targets & Performance Metrics ``targets_db``
  - The second dataset defines monthly business objectives and operational benchmarks, allowing for structured performance evaluations.

  - Trip Completion Goals `monthly_target_trips` – Establishes monthly trip targets per city to measure demand fulfillment.
  - New Customer Acquisition `monthly_target_new_passenger` – Sets growth targets for first-time passengers, helping assess market expansion efforts.
  - Passenger Experience `city_target_passenger_rating` – Defines expected passenger ratings to track and enhance service quality.

By leveraging this data-driven approach, Good Cabs can align its operational performance with strategic business goals, improve customer engagement, and refine decision-making to maximize efficiency and profitability.

![Data Model](
