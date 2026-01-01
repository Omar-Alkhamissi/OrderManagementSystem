-- Function 1: Returns the average order amount for a specific customer.
CREATE OR ALTER FUNCTION ufnGetCustomerAvgOrderAmount(@cust_in VARCHAR(6))
RETURNS MONEY
AS
BEGIN
    DECLARE @avg_order_amount MONEY;
    DECLARE @total_amount MONEY;
    SELECT @total_amount = SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))
    FROM OrderDetails od
    INNER JOIN Orders o ON od.OrderID = o.OrderID
    WHERE o.CustomerID = @cust_in;

    DECLARE @order_count INT;
    SELECT @order_count = COUNT(*)
    FROM Orders
    WHERE CustomerID = @cust_in;

    SET @avg_order_amount = ISNULL(@total_amount / NULLIF(@order_count, 0), 0);

    RETURN @avg_order_amount;
END;
GO

-- Function 2: Returns the average order amount for all companies
CREATE OR ALTER FUNCTION ufnGetAverageOrderAmountForAllCompanies()
RETURNS MONEY
AS
BEGIN
    DECLARE @avg_order_amount MONEY;

    DECLARE @total_amount MONEY;
    SELECT @total_amount = SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))
    FROM OrderDetails od;

    DECLARE @order_count INT;
    SELECT @order_count = COUNT(*)
    FROM Orders;

    SET @avg_order_amount = ISNULL(@total_amount / NULLIF(@order_count, 0), 0);

    RETURN @avg_order_amount;
END;
GO

-- Function 3: Returns the number of shipped orders for the selected customer
CREATE OR ALTER FUNCTION ufnGetShippedOrderCountForCustomer(@cust_in VARCHAR(6))
RETURNS INT
AS
BEGIN
    DECLARE @shipped_order_count INT;

    SELECT @shipped_order_count = COUNT(*)
    FROM Orders
    WHERE CustomerID = @cust_in AND ShippedDate IS NOT NULL;

    RETURN @shipped_order_count;
END;
GO

-- Stored Procedure: Retrieves order information
CREATE OR ALTER PROCEDURE uspGetOrderInformationForCustomer
    @cust_in VARCHAR(6)
AS
BEGIN
    DECLARE @current_date DATETIME;
    DECLARE @order_id SMALLINT;
    DECLARE @order_date DATE;
    DECLARE @shipped_indicator VARCHAR(11);
    DECLARE @total_amount MONEY;
    DECLARE @customer_name VARCHAR(255);

    SELECT @customer_name = CompanyName
    FROM Customers
    WHERE CustomerID = @cust_in;

    SET @current_date = GETDATE();

    DECLARE order_cursor CURSOR FOR
    SELECT o.OrderID, o.OrderDate
    FROM Orders o
    WHERE o.CustomerID = @cust_in
    ORDER BY (
        SELECT SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))
        FROM OrderDetails od
        WHERE od.OrderID = o.OrderID
    ) DESC;

    OPEN order_cursor;
    FETCH NEXT FROM order_cursor INTO @order_id, @order_date;

    PRINT 'Statistics for ' + @customer_name + ' ' + CONVERT(CHAR(14), FORMAT(@current_date, 'dd/MMM/yyyy')) +
          '- Omar Alkhamissi';
    PRINT 'Order #           Date                Status           Order Total';

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @total_amount = 0;

        IF (SELECT ShippedDate FROM Orders WHERE OrderID = @order_id) IS NULL
            SET @shipped_indicator = 'Not Shipped';
        ELSE
            SET @shipped_indicator = 'Shipped';

        DECLARE @unit_price MONEY;
        DECLARE @quantity SMALLINT;
        DECLARE @discount DECIMAL(2, 2);
        
        DECLARE order_details_cursor CURSOR FOR
        SELECT od.UnitPrice, od.Quantity, od.Discount
        FROM OrderDetails od
        WHERE od.OrderID = @order_id;

        OPEN order_details_cursor;
        FETCH NEXT FROM order_details_cursor INTO @unit_price, @quantity, @discount;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @total_amount = @total_amount + (@unit_price * @quantity * (1 - @discount));

            FETCH NEXT FROM order_details_cursor INTO @unit_price, @quantity, @discount;
        END;

        CLOSE order_details_cursor;
        DEALLOCATE order_details_cursor;

        PRINT RIGHT('0000' + CAST(@order_id AS VARCHAR(10)), 5) + '          ' +
              CONVERT(CHAR(14), FORMAT(@order_date, 'dd/MMM/yyyy')) + '         ' +
              LEFT(@shipped_indicator + '          ', 11) +
              RIGHT(SPACE(15) + FORMAT(@total_amount, 'C', 'en-us'), 15);

        FETCH NEXT FROM order_cursor INTO @order_id, @order_date;
    END;

    CLOSE order_cursor;
    DEALLOCATE order_cursor;

    DECLARE @avg_order_amount MONEY;
    SET @avg_order_amount = dbo.ufnGetCustomerAvgOrderAmount(@cust_in);
    PRINT '';
    PRINT 'Avg. order amount for customer: ' + FORMAT(@avg_order_amount, 'C', 'en-us');

    DECLARE @avg_order_amount_all_companies MONEY;
    SET @avg_order_amount_all_companies = dbo.ufnGetAverageOrderAmountForAllCompanies();
    PRINT 'Avg. order amount for company: ' + FORMAT(@avg_order_amount_all_companies, 'C', 'en-us');

    DECLARE @shipped_order_count INT;
    SET @shipped_order_count = dbo.ufnGetShippedOrderCountForCustomer(@cust_in);
    PRINT '# of orders this customer has shipped ' + @customer_name + ': ' + CAST(@shipped_order_count AS VARCHAR(10));
END;
GO

EXEC uspGetOrderInformationForCustomer 'LILAS';
