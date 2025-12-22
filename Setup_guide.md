# Olist Dashboard - Complete Setup Guide

## Prerequisites

- PostgreSQL 12+ installed
- Power BI Desktop installed (latest version)
- Olist dataset from Kaggle (8 CSV files)
- ~500 MB free disk space

---

## Part 1: PostgreSQL Setup (30 minutes)

### Step 1: Install PostgreSQL

**Windows:**
1. Download from https://www.postgresql.org/download/windows/
2. Run installer
3. Choose installation directory: `C:\Program Files\PostgreSQL\16`
4. Set password for `postgres` user (remember it!)
5. Port: 5432 (default)
6. Finish installation

**Mac:**
```bash
brew install postgresql@16
brew services start postgresql@16
psql --version  # Verify installation
```

**Linux (Ubuntu):**
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
psql --version  # Verify installation
```

---

### Step 2: Create Database

**Open Terminal/Command Prompt:**

```bash
psql -U postgres
```

Enter your PostgreSQL password when prompted.

**Inside psql console:**

```sql
CREATE DATABASE olist_ecommerce;
\c olist_ecommerce
\q
```

✅ Database created successfully

---

### Step 3: Create Tables

**Download the provided SQL files:**
1. `SQL_VIEWS.sql` (contains CREATE TABLE + CREATE VIEW statements)

**Run the CREATE TABLE statements:**

```bash
psql -U postgres -d olist_ecommerce -f SQL_VIEWS.sql
```

Or manually:

```bash
psql -U postgres -d olist_ecommerce
```

Then copy-paste all CREATE TABLE statements (first section of SQL_VIEWS.sql).

**Verify tables created:**
```sql
\dt
```

Should show 8 tables:
- customers
- sellers
- products
- category_translation
- orders
- order_items
- order_payments
- order_reviews

---

## Part 2: Load Data (30 minutes)

### Step 4: Download Olist Data from Kaggle

1. Go to: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
2. Download all 8 CSV files
3. Create folder: `C:\Data\Olist\` (Windows) or `/Users/YourName/Data/Olist/` (Mac)
4. Extract all CSVs to this folder

**Files should be:**
- olist_customers_dataset.csv
- olist_sellers_dataset.csv
- olist_products_dataset.csv
- olist_category_name_translation.csv
- olist_orders_dataset.csv
- olist_order_items_dataset.csv
- olist_order_payments_dataset.csv
- olist_order_reviews_dataset.csv

---

### Step 5: Import Data into PostgreSQL

**Option A: Using COPY Command (Fastest)**

Open psql and connect to database:
```bash
psql -U postgres -d olist_ecommerce
```

Run these COPY commands (adjust path based on your OS):

**Windows:**
```sql
COPY customers(customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state)
FROM 'C:/Data/Olist/olist_customers_dataset.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

COPY sellers(seller_id, seller_zip_code_prefix, seller_city, seller_state)
FROM 'C:/Data/Olist/olist_sellers_dataset.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

COPY products(product_id, product_category_name, product_name_length, product_description_length, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm)
FROM 'C:/Data/Olist/olist_products_dataset.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

COPY category_translation(product_category_name, product_category_name_english)
FROM 'C:/Data/Olist/olist_category_name_translation.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

COPY orders(order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date)
FROM 'C:/Data/Olist/olist_orders_dataset.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

COPY order_items(order_id, order_item_sequence, product_id, seller_id, shipping_limit_date, price, freight_value)
FROM 'C:/Data/Olist/olist_order_items_dataset.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

COPY order_payments(order_id, payment_sequential, payment_type, payment_installments, payment_value)
FROM 'C:/Data/Olist/olist_order_payments_dataset.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

COPY order_reviews(review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp)
FROM 'C:/Data/Olist/olist_order_reviews_dataset.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';
```

**Mac/Linux:**
Replace `C:/Data/Olist/` with `/Users/YourName/Data/Olist/`

---

### Step 6: Verify Data Loaded

```sql
SELECT COUNT(*) FROM customers;   -- Should be ~100,000
SELECT COUNT(*) FROM orders;      -- Should be ~100,000
SELECT COUNT(*) FROM order_items; -- Should be ~300,000
SELECT COUNT(*) FROM products;    -- Should be ~32,000
SELECT COUNT(*) FROM sellers;     -- Should be ~3,600
SELECT COUNT(*) FROM order_reviews; -- Should be ~100,000
```

If all counts match, data loaded successfully! ✅

---

## Part 3: Create SQL Views (1 hour)

### Step 7: Create All 8 Views

Copy-paste all CREATE VIEW statements from `SQL_VIEWS.sql` file into psql.

Or run file directly:
```bash
psql -U postgres -d olist_ecommerce -f SQL_VIEWS.sql
```

**Verify views created:**
```sql
\dv
```

Should show 8 views:
- v_product_performance
- v_category_performance
- v_daily_sales
- v_order_delivery
- v_seller_performance
- v_customer_behavior
- v_review_analysis
- v_payment_analysis

---

### Step 8: Test Views with Sample Queries

```sql
-- Test v_product_performance
SELECT * FROM v_product_performance LIMIT 5;

-- Test v_category_performance
SELECT * FROM v_category_performance LIMIT 5;

-- Test v_daily_sales
SELECT * FROM v_daily_sales ORDER BY order_date DESC LIMIT 5;
```

All should return data without errors ✅

---

## Part 4: Connect Power BI (15 minutes)

### Step 9: Open Power BI Desktop

1. Launch Power BI Desktop
2. Click **Home → Get Data**
3. Search for **PostgreSQL**
4. Click **PostgreSQL database**
5. Click **Connect**

---

### Step 10: Enter Database Credentials

**Server:** localhost
**Database:** olist_ecommerce

Click **OK**

**Enter credentials:**
- Username: postgres
- Password: (your PostgreSQL password)

Click **Connect**

---

### Step 11: Select Views to Load

You should see list of tables. **Select all 8 views:**
- ☑ v_product_performance
- ☑ v_category_performance
- ☑ v_daily_sales
- ☑ v_order_delivery
- ☑ v_seller_performance
- ☑ v_customer_behavior
- ☑ v_review_analysis
- ☑ v_payment_analysis

Click **Load**

⏳ Wait for data to load (2-3 minutes for 600K+ records)

---

## Part 5: Build Power BI Dashboard (3-4 hours)

### Step 12: Create Dashboard Pages

**Page 1: Executive Overview**
1. Add slicers: order_date (range), category
2. Add KPI cards: Total Revenue, Avg Order Value, Avg Review Score
3. Add line chart: Revenue trend (order_date vs total_revenue from v_daily_sales)
4. Add pie chart: Top 10 products (from v_product_performance)
5. Add pie chart: Payment methods (from v_payment_analysis)

**Page 2: Product Performance**
1. Add slicer: category (multi-select)
2. Add table: Top products (v_product_performance sorted by revenue)
3. Add scatter: Price vs Rating (avg_price vs avg_review_score)
4. Add bar chart: Review rate by category (v_category_performance)
5. Add scatter: Weight vs Freight (v_product_performance)

**Page 3: Delivery & Quality**
1. Add donut: Delivery status (v_order_delivery)
2. Add bar chart: Avg delivery days by state (v_order_delivery)
3. Add line chart: Satisfaction trend (order_date vs avg_review_score)
4. Add bar chart: Category ratings (v_category_performance sorted ascending)
5. Add KPI: On-Time Delivery %

**Page 4: Customer Intelligence**
1. Add map: Revenue by state (customer_state from v_customer_behavior)
2. Add table: Top 20 customers by spend (v_customer_behavior)
3. Add scatter: Orders vs Total Spent (x: total_orders, y: total_spent)
4. Add donut: Customer segments (1-time, 2-3 orders, 4-5, 6+)
5. Add line chart: New customers trend (order_date from v_daily_sales)

**Page 5: Seller Performance**
1. Add slicer: seller_state
2. Add table: Top sellers (v_seller_performance)
3. Add bar chart: Sellers by state (seller_state from v_seller_performance)
4. Add scatter: Products vs Revenue (product count vs revenue)
5. Add pie chart: Payment methods (v_payment_analysis)

---

### Step 13: Add DAX Measures

In Power BI, create measures (right-click table → New Measure):

```dax
Total Revenue = SUM(v_daily_sales[total_revenue])
Total Orders = DISTINCTCOUNT(v_daily_sales[total_orders])
Avg Order Value = DIVIDE([Total Revenue], [Total Orders])
On-Time Delivery % = COUNTIF(v_order_delivery[delivery_status], "On Time") / COUNTA(v_order_delivery[delivery_status])
Avg Review Score = AVERAGE(v_review_analysis[avg_score])
```

[See DAX_MEASURES.md for all 35+ measures]

---

### Step 14: Format & Polish

1. **Colors:** Use consistent blue/orange/green scheme
2. **Titles:** Add descriptive page titles
3. **Tooltips:** Custom tooltips on all visuals
4. **Conditional Formatting:** Red-yellow-green on KPIs
5. **Mobile Layout:** Optimize for phone viewing
6. **Save:** Save as `olist_dashboard.pbix`

---

## Part 6: Export to GitHub (30 minutes)

### Step 15: Create GitHub Repository

1. Go to GitHub.com
2. Create new repository: `olist-dashboard`
3. Add description: "Olist E-Commerce Dashboard - SQL + DAX + Power BI"
4. Initialize with README

---

### Step 16: Upload Files

**Clone repository locally:**
```bash
git clone https://github.com/yourusername/olist-dashboard.git
cd olist-dashboard
```

**Add files to repository:**
```bash
# Copy these files into the folder:
# 1. README.md (provided)
# 2. SQL_VIEWS.sql (provided)
# 3. SQL_QUERIES.sql (provided)
# 4. DAX_MEASURES.md (provided)
# 5. DATA_DICTIONARY.md (provided)
# 6. olist_dashboard.pbix (your Power BI file)
# 7. SETUP_GUIDE.md (this file)

git add .
git commit -m "Initial commit: Olist E-Commerce Dashboard"
git push origin main
```

---

## Troubleshooting

### PostgreSQL Issues

**Error: "role postgres does not exist"**
```bash
sudo -u postgres psql
```

**Error: "permission denied for schema public"**
```sql
GRANT ALL PRIVILEGES ON SCHEMA public TO postgres;
```

**Error: "COPY command failed"**
- Check file path (use forward slashes even on Windows)
- Verify CSV file exists at specified path
- Check CSV is UTF-8 encoded

---

### Power BI Issues

**Error: "Connection timeout"**
- Verify PostgreSQL is running
- Check localhost:5432 is accessible
- Verify firewall allows PostgreSQL

**Error: "views not showing in navigator"**
- Disconnect and reconnect
- Manually select tables instead of auto-detect
- Check user has permission to view schema

**Performance slow:**
- Reduce data range in Power BI slicers
- Use Import mode instead of DirectQuery
- Refresh views in PostgreSQL

---

### Data Loading Issues

**Fewer rows than expected:**
- Check for NULL values in CSV
- Verify COPY command matched column order
- Check CSV has proper headers

**Date format errors:**
- Ensure dates are YYYY-MM-DD format
- Use PostgreSQL date parsing functions if needed

---

## Verification Checklist

- [ ] PostgreSQL installed and running
- [ ] Database `olist_ecommerce` created
- [ ] 8 tables created with correct schemas
- [ ] All CSVs loaded (row counts verified)
- [ ] 8 SQL views created and tested
- [ ] Power BI connects to PostgreSQL
- [ ] All 8 views loaded in Power BI
- [ ] 5 dashboard pages created
- [ ] KPI cards working
- [ ] Slicers filtering correctly
- [ ] All visuals showing data
- [ ] DAX measures calculated correctly
- [ ] Dashboard saved as .pbix file
- [ ] Files uploaded to GitHub

---

## Next Steps

1. **Explore the Dashboard:** Interact with slicers, hover for tooltips
2. **Share with Others:** Export Power BI file or publish to Power BI Service
3. **Create Case Study:** Write how this dashboard helps decision-making
4. **LinkedIn Post:** Share dashboard screenshot with GitHub link
5. **Interview Talking Points:** Discuss SQL complexity, DAX measures, business insights

---

## Support Resources

- **PostgreSQL Docs:** https://www.postgresql.org/docs/
- **Power BI Docs:** https://docs.microsoft.com/en-us/power-bi/
- **DAX Function Reference:** https://dax.guide/
- **SQL Tutorial:** https://www.sqlservercentral.com/
- **Olist Dataset:** https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

---

## Timeline Summary

| Phase | Task | Time | Cumulative |
|-------|------|------|-----------|
| 1 | PostgreSQL setup | 30 min | 30 min |
| 2 | Download & load data | 30 min | 1 hr |
| 3 | Create views | 1 hr | 2 hrs |
| 4 | Connect Power BI | 15 min | 2.25 hrs |
| 5 | Build dashboard | 3-4 hrs | 5.25-6.25 hrs |
| 6 | Export to GitHub | 30 min | 6-7 hrs |

**Total Time: 6-7 hours spread over 1-2 weeks**

---

## Success Criteria

✅ All 8 views return data
✅ Power BI loads all views without errors
✅ Dashboard has 5 pages with 40+ visuals
✅ All slicers cross-filter correctly
✅ KPI cards display correct values
✅ DAX measures calculate properly
✅ GitHub repository has all 7 files
✅ README.md is clear and professional
✅ Dashboard is saved and shareable

**Congratulations! Your portfolio project is complete!** 🎉