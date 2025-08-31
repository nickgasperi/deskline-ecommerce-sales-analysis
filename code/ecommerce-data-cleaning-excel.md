# Data Cleaning & Preparation

* The original dataset containing all records was split into three tables: **products**, **customers**, and **orders**.
* 

## customers
**Existing Columns**
* `customer_id`, `customer_first_name`, `customer_last_name`

**Context**
* `customer_id` values are not assigned to customers with a 1:1 relationship in the original dataset. Created new `customer_id` column to serve as unique identifier.
* In a professional setting, since multiple customers may have the same name, I always incorporate additional data to ensure a 1:1 ratio is established, such as a phone number, SSN, or date of birth. This dataset does not include sufficient data for this, so for the sake of the exercise, each unique name will be paired with one `customer_id`.
* These customer-related columns were taken from the original dataset, so duplicates will be removed to identify only unique customer names.

**Tasks**
* Replace unique identifier `customer_id` values with appropriate values
      
        # combine customer_first_name and customer_last_name into column D
        =CONCAT(C2, ", ", B2)
            -> apply formula down to all records
            -> copy + paste values
        
        # print unique list of names in column E
        =UNIQUE(D2:D113271)
            -> copy + paste values
        
        # create unique identifier with a numbered list in column F
        =SEQUENCE(COUNTA(E2:E46555), 1, 1, 1)
            -> copy + paste values

        -> delete columns A:D
        -> print 'customer_id' in cell B1 as column title
        -> print 'customer_last_name' in cell C2 as column title
        -> print 'customer_first_name' in cell D2 as column title

        # full name now sits in column A and `customer_id` is in column B
        # split the full name column back to the original separate first and last name columns (place formula in column C)
        =TEXTSPLIT(A2, ", ")
            -> apply formula down to all records
            -> copy + paste values
            -> delete column A        

## products
**Existing Columns**
* `category_name`, `product_name`

**Context**
* The original dataset did not include a unique identifier for the products listed.
* `product_id` must be established in **products** before preparing **orders** table.
* These product-related columns were taken from the original dataset, so duplicates will be removed to identify only unique products.

**Tasks**
* create `product_id` column as unique identifier
        
        -> print 'product_id' into cell D1 as column title
        -> print 'product_name' into cell E1 as column title
        -> print 'product_category' into cell E1 as column title
                
        # print unique list of products from `product_name` into column E
        =UNIQUE(B2:B113271)
            -> copy + paste values

        # create unique identifier with a numbered list in column D
        =SEQUENCE(COUNTA(E2:E1850), 1, 1, 1)
            -> copy + paste values

        # apply corresponding category to all products listed in column E (formula in column F)
        =XLOOKUP(E2, $A$2:$A$113271, $B$2:$B$113271)
            -> apply formula down to all records
            -> copy + paste values
            -> delete columns A:C

## orders
**Existing Columns**
* `customer_first_name`, `customer_last_name`, `category_name`, `product_name`, `customer_segment`, `customer_city`, `customer_state`, `customer_country`, `customer_region`, `delivery_status`, `order_date`, `order_id`, `ship_date`, `shipping_type`, `days_for_shipment_scheduled`, `days_for_shipment_real`, `order_item_discount`, `sales_per_order`, `order_quantity`, `profit_per_order`

**Context**

**Tasks**
* replace `customer_first_name` and `customer_last_name` columns with `customer_id`

        -> insert new column to the left of column A
        -> print 'customer_id' into cell A1 as column title

        # create temporary column for full customer name in column X
        =CONCAT(C2, ", ", B2)
            -> apply formula down to all records
            -> copy + paste values

        -> copy and paste all three columns from customers table into columns Z:AB

        # create another temporary column for full customer name for lookup table in column AC
        =CONCAT(AB2, ", ", AA2)
            -> apply formula down to all records
            -> copy + paste values        

        # apply unique identifier to all records by matching `customer_id` to each full customer name in the lookup table
        =XLOOKUP(X2, $AC$2:$AC$113271, $Z$2:$Z$113271)
            -> apply formula down to all records
            -> copy + paste values
            -> check for null values and errors
            -> delete columns X:AC to clear lookup tables
            -> delete columns B:C to clear customer first name and last name fields

* replace `product_name` and `category_name` with `product_id`
        
        -> delete `category_name` column
        -> insert new column to the left of column B
        -> print 'product_id' into cell B1 as column title
        -> copy and paste `product_name` and `product_id` columns from customers table into columns U:V

        # apply unique identifier to all records by matching `product_id` to each `product_name` in the table
        =XLOOKUP(C2, $U$2:$U$113271, $V$2:$V$113271)
            -> apply formula down to all records
            -> copy + paste values
            -> check for null values and errors
            -> delete columns U:V to clear lookup table
            -> delete column C to clear `product_name` values

* standardize `order_date` and `ship_date` values to m/d/yyyy format
  * values in both columns contain dates with two different formats: dd-mm-yyy and m/d/yyyy
  * this fix is easy - excel reads the m/d/yyyy format as a number, but does not recognize values with dd-mm-yyyy format as numeric.  

        -> insert new column to the left of column I
        -> print 'order_date' into cell I1 as column title
        
        # if `order_date` value is a number, print "", else split the date
        =IF(ISNUMBER(I2), "", TEXTSPLIT(I2, "-"))
            -> apply formula down to all records
            -> copy and paste values
            -> change data type to whole number
        
        # if date is already correct, then print date, else rebuild the date using split values
        =IF(T2="", J2, CONCAT(U2, "/", T2, "/", V2))
            -> apply formula down to all records
            -> copy and paste values
            -> change data type to short date
            -> delete column J to clear original `order_date` column
            -> delete columns T:V to clear lookup table
        
        -> repeat process for `ship_date` column         

* replace existing `order_id` values with numerical values
  * current `order_id` values stored as: 'O_ID_3001072'
  * since all values are 12 characters long, simply extract the numeric portion of each value

        -> insert new column to the left of column K
        -> print 'order_id' in cell K1 as column title
        
        =RIGHT(L2, 7)
            -> apply formula down to all records
            -> copy + paste values
            -> change data type to number
            -> check for duplicate values
            -> delete column L to clear original `order_id` column

* insert `order_month` and `order_year` columns

        -> insert new column to the left of column J
        -> print 'order_year' in cell J1 as column title

        # extract year from `order_date` into new column
        =TEXT(I2, "YYYY")
            -> apply formula down to all records
            -> copy and paste values

        # repeat for order month
        -> insert new column to the left of column J
        -> print 'order_month' in cell J1 as column title

        # use 3 m's to pull abbreviated month name
        =TEXT(I2, "MMM")
            -> apply formula down to all records
            -> copy and paste values

* clean up column title names in row 1

        ship_date -> date_shipped
        days_for_shipment_scheduled -> est_ship_days
        days_for_shipment_real -> actual_ship_days
        profit_per_order -> profit_usd
        sales_per_order -> sales_usd
        order_quantity -> item_quantity
        order_item_discount -> discount_usd
        delivery_status -> delivery_result