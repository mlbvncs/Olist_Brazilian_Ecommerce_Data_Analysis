-- Creating primary keys (PK)
ALTER TABLE orders ADD PRIMARY KEY (order_id);
ALTER TABLE customers ADD PRIMARY KEY (customer_id);
ALTER TABLE sellers ADD PRIMARY KEY (seller_id);
ALTER TABLE products ADD PRIMARY KEY (product_id);
ALTER TABLE order_items ADD PRIMARY KEY (order_id, order_item_id);
ALTER TABLE order_reviews ADD PRIMARY KEY (review_id);
ALTER TABLE order_payments ADD PRIMARY KEY (order_id, payment_sequential);
ALTER TABLE category_translation ADD PRIMARY KEY (product_category_name);

-- Creating foreign keys (FK)
-- orders → customers
ALTER TABLE orders ADD FOREIGN KEY (customer_id) REFERENCES customers(customer_id);
-- order_items → orders
ALTER TABLE order_items ADD FOREIGN KEY (order_id) REFERENCES orders(order_id);
-- order_items → sellers
ALTER TABLE order_items ADD FOREIGN KEY (seller_id) REFERENCES sellers(seller_id);
-- order_items → products
ALTER TABLE order_items ADD FOREIGN KEY (product_id) REFERENCES products(product_id);
-- order_reviews → orders
ALTER TABLE order_reviews ADD FOREIGN KEY (order_id) REFERENCES orders(order_id);
-- order_payments → orders
ALTER TABLE order_payments ADD FOREIGN KEY (order_id) REFERENCES orders(order_id);
-- products → category_translation
ALTER TABLE products ADD FOREIGN KEY (product_category_name) REFERENCES category_translation(product_category_name);