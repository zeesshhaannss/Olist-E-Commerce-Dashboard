# Olist Dashboard - Complete DAX Measures Library

## Table of Contents
1. [Revenue Measures](#revenue)
2. [Order & Customer Measures](#orders-customers)
3. [Product Measures](#products)
4. [Delivery Measures](#delivery)
5. [Review & Satisfaction Measures](#satisfaction)
6. [Seller Measures](#sellers)
7. [Payment Measures](#payments)
8. [Time Intelligence Measures](#time-intelligence)

---

## Revenue Measures {#revenue}

### Total Revenue
```dax
Total Revenue = 
SUM(v_daily_sales[total_revenue])
```
**Purpose:** Total money earned including product price and shipping
**Used In:** Executive Overview KPI card, all trend charts
**Expected Value:** R$ 15.9M

---

### Total Net Revenue (Product Only)
```dax
Total Net Revenue = 
SUM(v_daily_sales[total_revenue]) - SUM(v_daily_sales[total_freight])
```
**Purpose:** Product revenue excluding shipping costs
**Used In:** Profitability analysis

---

### Total Freight Cost
```dax
Total Freight Cost = 
SUM(v_daily_sales[total_freight])
```
**Purpose:** Total shipping costs
**Used In:** Logistics analysis, product profitability

---

### Freight as % of Revenue
```dax
Freight % of Revenue = 
DIVIDE([Total Freight Cost], [Total Revenue], 0) * 100
```
**Purpose:** Percentage of revenue spent on shipping
**Used In:** Cost efficiency analysis

---

### Revenue per Item
```dax
Revenue per Item = 
DIVIDE([Total Revenue], SUM(v_daily_sales[total_items]), 0)
```
**Purpose:** Average revenue per item sold
**Used In:** Item-level profitability

---

## Order & Customer Measures {#orders-customers}

### Total Orders
```dax
Total Orders = 
DISTINCTCOUNT(v_daily_sales[total_orders])
```
**Purpose:** Count of unique orders (not items)
**Used In:** All pages, baseline metric
**Expected Value:** ~100,000

---

### Total Items Sold
```dax
Total Items Sold = 
SUM(v_daily_sales[total_items])
```
**Purpose:** Total line items across all orders
**Used In:** Volume metrics
**Expected Value:** ~300,000

---

### Avg Order Value (AOV)
```dax
Avg Order Value = 
DIVIDE([Total Revenue], [Total Orders], 0)
```
**Purpose:** Average customer spend per order
**Used In:** Executive KPI, trend tracking
**Expected Value:** R$ 159

---

### Unique Customers
```dax
Total Customers = 
DISTINCTCOUNT(v_customer_behavior[customer_id])
```
**Purpose:** Count of unique customer IDs
**Used In:** Customer page KPI
**Expected Value:** ~100,000

---

### Orders per Customer
```dax
Orders per Customer = 
DIVIDE([Total Orders], [Total Customers], 0)
```
**Purpose:** Average orders per customer (loyalty indicator)
**Used In:** Customer behavior analysis

---

### Customer Lifetime Value (CLV)
```dax
Customer Lifetime Value = 
DIVIDE(
    SUMX(
        VALUES(v_customer_behavior[customer_id]),
        [Total Revenue]
    ),
    [Total Customers],
    0
)
```
**Purpose:** Average total spend per customer
**Used In:** Customer Intelligence page
**Expected Value:** R$ 487

---

### Repeat Customer Rate %
```dax
Repeat Customer Rate % = 
DIVIDE(
    CALCULATE(
        DISTINCTCOUNT(v_customer_behavior[customer_id]),
        FILTER(v_customer_behavior, v_customer_behavior[total_orders] > 1)
    ),
    [Total Customers],
    0
) * 100
```
**Purpose:** % of customers who ordered more than once
**Used In:** Customer segments, loyalty metric
**Expected Value:** 47%

---

### One-Time Buyers
```dax
One-Time Buyers = 
CALCULATE(
    DISTINCTCOUNT(v_customer_behavior[customer_id]),
    FILTER(v_customer_behavior, v_customer_behavior[total_orders] = 1)
)
```
**Purpose:** Count of customers who only ordered once
**Used In:** Customer segment analysis

---

### Repeat Customers (2+ Orders)
```dax
Repeat Customers = 
CALCULATE(
    DISTINCTCOUNT(v_customer_behavior[customer_id]),
    FILTER(v_customer_behavior, v_customer_behavior[total_orders] > 1)
)
```
**Purpose:** Count of customers with multiple orders
**Used In:** Loyalty metric

---

### New Customers This Month
```dax
New Customers This Month = 
CALCULATE(
    DISTINCTCOUNT(v_customer_behavior[customer_id]),
    FILTER(
        ALL(v_customer_behavior),
        MONTH(v_customer_behavior[first_order_date]) = MONTH(TODAY()),
        YEAR(v_customer_behavior[first_order_date]) = YEAR(TODAY())
    )
)
```
**Purpose:** Monthly customer acquisition count
**Used In:** Customer Intelligence page

---

## Product Measures {#products}

### Total Products
```dax
Total Products = 
DISTINCTCOUNT(v_product_performance[product_id])
```
**Purpose:** Count of unique product SKUs
**Used In:** Product performance page
**Expected Value:** ~32,000

---

### Avg Product Price
```dax
Avg Product Price = 
AVERAGE(v_product_performance[avg_price])
```
**Purpose:** Average selling price of products
**Used In:** Product analysis

---

### Products with 4+ Star Rating
```dax
High-Rated Products = 
CALCULATE(
    DISTINCTCOUNT(v_product_performance[product_id]),
    FILTER(v_product_performance, v_product_performance[avg_review_score] >= 4)
)
```
**Purpose:** Count of products rated 4+ stars
**Used In:** Quality assessment

---

### Products with Low Rating (<3 Stars)
```dax
Low-Rated Products = 
CALCULATE(
    DISTINCTCOUNT(v_product_performance[product_id]),
    FILTER(v_product_performance, v_product_performance[avg_review_score] < 3)
)
```
**Purpose:** Count of problem products needing attention
**Used In:** Quality alert

---

### Avg Category Revenue
```dax
Avg Category Revenue = 
DIVIDE(
    [Total Revenue],
    DISTINCTCOUNT(v_category_performance[category]),
    0
)
```
**Purpose:** Average revenue per category
**Used In:** Category benchmarking

---

### Top Category
```dax
Top Category = 
CALCULATE(
    MAX(v_category_performance[category]),
    TOPN(1, ALL(v_category_performance), [Total Revenue], DESC)
)
```
**Purpose:** Name of highest revenue category
**Used In:** Highlights card

---

### Top Product by Revenue
```dax
Top Product = 
CALCULATE(
    MAX(v_product_performance[product_id]),
    TOPN(1, ALL(v_product_performance), v_product_performance[total_revenue], DESC)
)
```
**Purpose:** Name of bestselling product
**Used In:** Highlights

---

## Delivery Measures {#delivery}

### Total Orders Delivered
```dax
Total Orders Delivered = 
CALCULATE(
    DISTINCTCOUNT(v_order_delivery[order_id]),
    FILTER(v_order_delivery, v_order_delivery[delivery_status] <> "Not Delivered")
)
```
**Purpose:** Count of delivered orders
**Used In:** Delivery metrics

---

### On-Time Delivery Count
```dax
On-Time Orders = 
CALCULATE(
    DISTINCTCOUNT(v_order_delivery[order_id]),
    FILTER(v_order_delivery, v_order_delivery[delivery_status] = "On Time")
)
```
**Purpose:** Count of orders delivered on time
**Used In:** Delivery status breakdown

---

### On-Time Delivery %
```dax
On-Time Delivery % = 
DIVIDE(
    [On-Time Orders],
    [Total Orders Delivered],
    0
) * 100
```
**Purpose:** % of orders delivered by promised date
**Used In:** Delivery page KPI card
**Expected Value:** 92%

---

### Late Delivery Count
```dax
Late Orders = 
CALCULATE(
    DISTINCTCOUNT(v_order_delivery[order_id]),
    FILTER(v_order_delivery, v_order_delivery[delivery_status] = "Late")
)
```
**Purpose:** Count of orders delivered late
**Used In:** Delivery status breakdown

---

### Late Delivery %
```dax
Late Delivery % = 
DIVIDE(
    [Late Orders],
    [Total Orders Delivered],
    0
) * 100
```
**Purpose:** % of orders delivered after promised date
**Used In:** Delivery quality metric

---

### Not Delivered Count
```dax
Not Delivered = 
CALCULATE(
    DISTINCTCOUNT(v_order_delivery[order_id]),
    FILTER(v_order_delivery, v_order_delivery[delivery_status] = "Not Delivered")
)
```
**Purpose:** Count of orders not yet delivered
**Used In:** Pending orders tracking

---

### Average Delivery Days
```dax
Avg Delivery Days = 
AVERAGE(v_order_delivery[delivery_days])
```
**Purpose:** Average days from order to delivery
**Used In:** Delivery page KPI, state comparison
**Expected Value:** 13.8 days

---

### Delivery Variance (Days Late/Early)
```dax
Avg Delivery Variance = 
AVERAGE(v_order_delivery[delivery_variance_days])
```
**Purpose:** Average days late (negative = early)
**Used In:** Delivery performance analysis

---

## Review & Satisfaction Measures {#satisfaction}

### Average Review Score
```dax
Avg Review Score = 
AVERAGE(v_review_analysis[avg_score])
```
**Purpose:** Average rating across all reviews (1-5 scale)
**Used In:** Executive Overview gauge, all quality metrics
**Expected Value:** 4.1/5

---

### Total Reviews
```dax
Total Reviews = 
DISTINCTCOUNT(v_review_analysis[review_id])
```
**Purpose:** Count of customer reviews received
**Used In:** Review volume tracking
**Expected Value:** ~100,000

---

### Review Rate %
```dax
Review Rate % = 
DIVIDE(
    [Total Reviews],
    [Total Orders],
    0
) * 100
```
**Purpose:** % of orders that received reviews
**Used In:** Customer engagement metric

---

### 5-Star Reviews
```dax
5-Star Reviews = 
CALCULATE(
    SUM(v_review_analysis[review_count]),
    FILTER(v_review_analysis, v_review_analysis[review_score] = 5)
)
```
**Purpose:** Count of 5-star reviews
**Used In:** Quality distribution

---

### 5-Star Reviews %
```dax
5-Star Reviews % = 
DIVIDE(
    [5-Star Reviews],
    [Total Reviews],
    0
) * 100
```
**Purpose:** % of reviews that are 5-star
**Used In:** Quality perception

---

### 4-Star Reviews
```dax
4-Star Reviews = 
CALCULATE(
    SUM(v_review_analysis[review_count]),
    FILTER(v_review_analysis, v_review_analysis[review_score] = 4)
)
```
**Purpose:** Count of 4-star reviews
**Used In:** Quality distribution

---

### 4-Star Reviews %
```dax
4-Star Reviews % = 
DIVIDE(
    [4-Star Reviews],
    [Total Reviews],
    0
) * 100
```
**Purpose:** % of reviews that are 4-star
**Used In:** Quality distribution chart

---

### Negative Reviews (1-2 Stars)
```dax
Negative Reviews = 
CALCULATE(
    SUM(v_review_analysis[review_count]),
    FILTER(v_review_analysis, v_review_analysis[review_score] <= 2)
)
```
**Purpose:** Count of negative reviews
**Used In:** Problem identification

---

### Negative Reviews %
```dax
Negative Reviews % = 
DIVIDE(
    [Negative Reviews],
    [Total Reviews],
    0
) * 100
```
**Purpose:** % of negative reviews
**Used In:** Quality alert metric

---

### Positive Reviews (4-5 Stars)
```dax
Positive Reviews = 
[4-Star Reviews] + [5-Star Reviews]
```
**Purpose:** Count of satisfied customers
**Used In:** Satisfaction metric

---

### Positive Reviews %
```dax
Positive Reviews % = 
DIVIDE(
    [Positive Reviews],
    [Total Reviews],
    0
) * 100
```
**Purpose:** % of positive reviews
**Used In:** Overall satisfaction metric
**Expected Value:** ~80%

---

## Seller Measures {#sellers}

### Total Sellers
```dax
Total Sellers = 
DISTINCTCOUNT(v_seller_performance[seller_id])
```
**Purpose:** Count of active sellers
**Used In:** Seller page KPI
**Expected Value:** ~3,600

---

### Avg Seller Rating
```dax
Avg Seller Rating = 
AVERAGE(v_seller_performance[avg_review_score])
```
**Purpose:** Average rating across all sellers
**Used In:** Seller quality metric

---

### Top Seller Revenue
```dax
Top Seller Revenue = 
MAXX(
    TOPN(1, ALL(v_seller_performance), v_seller_performance[total_revenue], DESC),
    v_seller_performance[total_revenue]
)
```
**Purpose:** Revenue of highest-performing seller
**Used In:** Seller highlights

---

### Positive Review % by Seller
```dax
Seller Positive Review % = 
AVERAGE(v_seller_performance[positive_review_pct])
```
**Purpose:** Average positive review % across all sellers
**Used In:** Seller quality benchmark

---

## Payment Measures {#payments}

### Credit Card Orders
```dax
Credit Card Orders = 
CALCULATE(
    SUM(v_payment_analysis[total_orders]),
    FILTER(v_payment_analysis, v_payment_analysis[payment_type] = "credit_card")
)
```
**Purpose:** Count of credit card payments
**Used In:** Payment method breakdown

---

### Credit Card Orders %
```dax
Credit Card Orders % = 
DIVIDE(
    [Credit Card Orders],
    SUM(v_payment_analysis[total_orders]),
    0
) * 100
```
**Purpose:** % of orders paid with credit card
**Used In:** Payment method pie chart
**Expected Value:** 75%

---

### Debit Card Orders %
```dax
Debit Card Orders % = 
DIVIDE(
    CALCULATE(
        SUM(v_payment_analysis[total_orders]),
        FILTER(v_payment_analysis, v_payment_analysis[payment_type] = "debit_card")
    ),
    SUM(v_payment_analysis[total_orders]),
    0
) * 100
```
**Purpose:** % of orders paid with debit card
**Used In:** Payment method breakdown

---

### Boleto Orders %
```dax
Boleto Orders % = 
DIVIDE(
    CALCULATE(
        SUM(v_payment_analysis[total_orders]),
        FILTER(v_payment_analysis, v_payment_analysis[payment_type] = "boleto")
    ),
    SUM(v_payment_analysis[total_orders]),
    0
) * 100
```
**Purpose:** % of orders paid with Boleto (Brazilian payment)
**Used In:** Payment method breakdown

---

### Avg Payment Value
```dax
Avg Payment Value = 
AVERAGE(v_payment_analysis[avg_payment_value])
```
**Purpose:** Average payment amount
**Used In:** Payment analysis

---

### Orders with Installments
```dax
Orders with Installments = 
CALCULATE(
    SUM(v_payment_analysis[total_orders]),
    FILTER(v_payment_analysis, v_payment_analysis[payment_type] = "credit_card")
)
```
**Purpose:** Count of installment payments
**Used In:** Installment analysis

---

### Avg Installments
```dax
Avg Installments = 
CALCULATE(
    AVERAGE(v_payment_analysis[avg_installments]),
    FILTER(v_payment_analysis, v_payment_analysis[payment_type] = "credit_card")
)
```
**Purpose:** Average number of installments
**Used In:** Payment flexibility analysis

---

## Time Intelligence Measures {#time-intelligence}

### Revenue This Month (MTD)
```dax
Revenue MTD = 
CALCULATE(
    [Total Revenue],
    DATESMTD(v_daily_sales[order_date])
)
```
**Purpose:** Month-to-date revenue
**Used In:** Current month tracking

---

### Revenue This Year (YTD)
```dax
Revenue YTD = 
CALCULATE(
    [Total Revenue],
    DATESYTD(v_daily_sales[order_date])
)
```
**Purpose:** Year-to-date revenue
**Used In:** Annual tracking

---

### Revenue Previous Month
```dax
Revenue Previous Month = 
CALCULATE(
    [Total Revenue],
    PREVIOUSMONTH(v_daily_sales[order_date])
)
```
**Purpose:** Last month's revenue for comparison
**Used In:** Month-over-month analysis

---

### Revenue Same Period Last Year
```dax
Revenue Last Year = 
CALCULATE(
    [Total Revenue],
    SAMEPERIODLASTYEAR(v_daily_sales[order_date])
)
```
**Purpose:** Revenue from same period previous year
**Used In:** YoY growth calculation

---

### Year-over-Year Growth %
```dax
YoY Growth % = 
IFERROR(
    DIVIDE(
        ([Total Revenue] - [Revenue Last Year]),
        [Revenue Last Year],
        0
    ) * 100,
    0
)
```
**Purpose:** Year-on-year revenue growth percentage
**Used In:** Executive KPI card
**Expected Value:** ~12%

---

### Month-over-Month Growth %
```dax
MoM Growth % = 
IFERROR(
    DIVIDE(
        ([Revenue This Month] - [Revenue Previous Month]),
        [Revenue Previous Month],
        0
    ) * 100,
    0
)
```
**Purpose:** Month-to-month growth rate
**Used In:** Trend line analysis

---

### Is Current Month
```dax
Is Current Month = 
IF(
    MONTH(v_daily_sales[order_date]) = MONTH(TODAY()),
    "Yes",
    "No"
)
```
**Purpose:** Filter flag for current month
**Used In:** Slicer filtering

---

### Days in Month
```dax
Days in Month = 
DAY(
    EOMONTH(v_daily_sales[order_date], 0)
)
```
**Purpose:** Number of days in selected month
**Used In:** Daily average calculations

---

### Revenue per Day (Average)
```dax
Revenue per Day = 
DIVIDE(
    [Total Revenue],
    DISTINCTCOUNT(v_daily_sales[order_date]),
    0
)
```
**Purpose:** Average daily revenue
**Used In:** Daily pace analysis

---

## Helper Measures (Support Calculations)

### Total Orders Count (Alternative)
```dax
Orders Count = 
COUNTA(v_daily_sales[total_orders])
```
**Purpose:** Alternative order count method
**Used In:** Data validation

---

### Blank Check (For Error Handling)
```dax
Is Blank = 
IF(ISBLANK([Total Revenue]), "No Data", "Has Data")
```
**Purpose:** Identify missing data
**Used In:** Data quality checks

---

## Tips for Using These Measures

1. **Copy exactly** - DAX is case-sensitive (use exact column names)
2. **Test after creating** - Create measure, then drag to a card visual to verify
3. **Use IFERROR** - Wrap measures in IFERROR() to handle division by zero
4. **Order of operations** - Create basic measures first, then advanced ones
5. **Naming convention** - Use clear, descriptive names (avoid spaces if possible)

---

## Measure Organization in Power BI

**Best Practice:** Create a "Measures" table to hold all calculations

```
Right-click table → New Table

Measures = 
ROW(
    "Revenue", [Total Revenue],
    "Orders", [Total Orders],
    "AOV", [Avg Order Value]
)
```

Then all measures appear together in the field list.

---

## Common Errors & Solutions

**Error:** "Column 'X' in table 'Y' cannot be found"
- **Solution:** Check exact column name spelling (case-sensitive)

**Error:** "A circular dependency was detected"
- **Solution:** Measure references another measure that references it back

**Error:** "The function CALCULATE is missing the filter argument"
- **Solution:** Add proper FILTER() clause or table reference

**Error:** "Values cannot be divided by zero"
- **Solution:** Wrap formula in DIVIDE() with 0 as default: DIVIDE(a, b, 0)

---

## Performance Notes

- **Avoid SUMPRODUCT** - Use CALCULATE + FILTER instead
- **Use DISTINCTCOUNT** - Not COUNT for unique values
- **Filter tables** - Not entire datasets in measures
- **Reference views** - Not base tables (views are pre-aggregated)
- **Separate logic** - Create multiple measures rather than one complex formula