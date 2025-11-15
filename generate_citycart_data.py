import csv
import random
from datetime import datetime, timedelta
from faker import Faker
import os

fake = Faker()

# ------------------------
# 1. Basic config
# ------------------------
NUM_CUSTOMERS = 100_000
NUM_PRODUCTS = 5_000
NUM_ORDERS = 800_000

NUM_DRIVERS = 5_000
NUM_WAREHOUSES = 20
NUM_CAMPAIGNS = 200
NUM_TICKETS = 100_000

CITIES = [
    ("Lagos", "Nigeria"),
    ("Nairobi", "Kenya"),
    ("Accra", "Ghana"),
    ("Kigali", "Rwanda"),
    ("Johannesburg", "South Africa"),
    ("Cairo", "Egypt"),
]

SIGNUP_CHANNELS = ["organic", "paid", "referral", "offline"]
GENDERS = ["male", "female", "other", "unknown"]
DEVICE_TYPES = ["android", "ios", "web"]
PAYMENT_METHODS = ["card", "wallet", "transfer", "cash_on_delivery"]
ORDER_STATUS = ["placed", "paid", "cancelled", "delivered", "refunded"]
PROMO_CODES = [None, "WELCOME10", "CITYCART5", "WEEKEND20", "HAPPYHOUR"]

CATEGORIES = ["Beverages", "Snacks", "Fruits", "Vegetables", "Dairy", "Household", "Meat"]
UNITS = ["kg", "piece", "pack"]

VEHICLE_TYPES = ["bike", "car", "van"]
EMPLOYMENT_TYPES = ["full_time", "part_time", "contract"]

CAMPAIGN_CHANNELS = ["facebook", "instagram", "tiktok", "google_ads", "email", "referral"]
CAMPAIGN_OBJECTIVES = ["acquisition", "retention", "reactivation", "upsell"]
ATTRIBUTION_MODELS = ["last_click", "first_click", "linear"]

TICKET_STATUS = ["open", "pending", "closed"]
TICKET_CATEGORIES = ["late_delivery", "missing_item", "wrong_item", "payment_issue", "app_bug", "other"]

DATA_DIR = "data_raw"
os.makedirs(DATA_DIR, exist_ok=True)

# Utility helpers
def random_date(start: datetime, end: datetime) -> datetime:
    """Return a random datetime between start and end."""
    delta = end - start
    random_seconds = random.randint(0, int(delta.total_seconds()))
    return start + timedelta(seconds=random_seconds)


# ------------------------
# 2. Generate customers
# ------------------------
customers = []

start_signup = datetime(2022, 1, 1)
end_signup = datetime(2025, 10, 31)

with open(os.path.join(DATA_DIR, "customers.csv"), mode="w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow([
        "customer_id", "first_name", "last_name", "email", "phone_number",
        "signup_date", "signup_channel", "city", "country",
        "birth_date", "gender", "is_premium", "deleted_at"
    ])

    for i in range(1, NUM_CUSTOMERS + 1):
        customer_id = f"CUST_{i:06d}"
        first_name = fake.first_name()
        last_name = fake.last_name()
        email = f"{first_name}.{last_name}{i}@example.com".lower()
        phone_number = fake.msisdn()

        signup_date = random_date(start_signup, end_signup)
        signup_channel = random.choice(SIGNUP_CHANNELS)
        city, country = random.choice(CITIES)

        # Birth date: some nulls, some realistic ages
        if random.random() < 0.2:
            birth_date = ""
        else:
            age = random.randint(18, 60)
            birth_date = (signup_date - timedelta(days=age * 365)).date().isoformat()

        gender = random.choice(GENDERS)
        is_premium = random.random() < 0.15  # 15% premium

        # Soft delete some customers
        if random.random() < 0.05:
            deleted_at = random_date(signup_date, end_signup).isoformat()
        else:
            deleted_at = ""

        writer.writerow([
            customer_id, first_name, last_name, email, phone_number,
            signup_date.isoformat(sep=" "),
            signup_channel, city, country,
            birth_date, gender, int(is_premium), deleted_at
        ])

        customers.append((customer_id, city, country))

print(f"Generated {NUM_CUSTOMERS} customers")


# ------------------------
# 3. Generate products
# ------------------------
products = []

with open(os.path.join(DATA_DIR, "products.csv"), mode="w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow([
        "product_id", "product_sku", "product_name",
        "category", "sub_category", "brand",
        "unit_of_measure", "standard_price", "cost_price",
        "is_active", "created_at", "updated_at"
    ])

    start_products = datetime(2021, 6, 1)
    end_products = datetime(2025, 10, 31)

    for i in range(1, NUM_PRODUCTS + 1):
        product_id = f"PROD_{i:05d}"
        product_sku = f"SKU{i:05d}"
        category = random.choice(CATEGORIES)
        sub_category = f"{category} - {fake.word().title()}"
        brand = fake.company()
        unit = random.choice(UNITS)

        # Prices: reasonable ranges
        cost_price = round(random.uniform(1, 20), 2)
        margin_multiplier = random.uniform(1.1, 1.8)
        standard_price = round(cost_price * margin_multiplier, 2)

        created_at = random_date(start_products, end_products)
        # some products recently updated
        if random.random() < 0.5:
            updated_at = random_date(created_at, end_products)
        else:
            updated_at = created_at

        is_active = random.random() > 0.1  # 90% active

        product_name = f"{brand} {category} {fake.color_name()}"

        writer.writerow([
            product_id, product_sku, product_name,
            category, sub_category, brand,
            unit, standard_price, cost_price,
            int(is_active), created_at.isoformat(sep=" "), updated_at.isoformat(sep=" ")
        ])

        products.append((product_id, standard_price, cost_price))

print(f"Generated {NUM_PRODUCTS} products")


# ------------------------
# 4. Generate orders and order_items
# ------------------------
orders_file = open(os.path.join(DATA_DIR, "orders.csv"), mode="w", newline="", encoding="utf-8")
order_items_file = open(os.path.join(DATA_DIR, "order_items.csv"), mode="w", newline="", encoding="utf-8")

orders_writer = csv.writer(orders_file)
items_writer = csv.writer(order_items_file)

orders_writer.writerow([
    "order_id", "customer_id", "order_datetime",
    "order_status", "payment_method", "city", "country",
    "device_type", "promo_code",
    "subtotal_amount", "discount_amount", "delivery_fee",
    "tip_amount", "total_amount", "currency",
    "created_at", "updated_at"
])

items_writer.writerow([
    "order_item_id", "order_id", "product_id",
    "quantity", "unit_price", "line_subtotal",
    "line_discount", "line_total", "created_at"
])

start_orders = datetime(2022, 1, 1)
end_orders = datetime(2025, 10, 31)

order_item_id = 1

# Track delivered orders for deliveries / marketing / tickets
delivered_orders = []   # (order_id, order_datetime, city, country, customer_id)

for i in range(1, NUM_ORDERS + 1):
    order_id = f"ORD_{i:07d}"
    customer_id, city, country = random.choice(customers)

    order_datetime = random_date(start_orders, end_orders)
    created_at = order_datetime
    updated_at = order_datetime + timedelta(minutes=random.randint(0, 120))

    device_type = random.choice(DEVICE_TYPES)
    payment_method = random.choice(PAYMENT_METHODS)

    # Order status distribution: majority delivered/paid
    rnd = random.random()
    if rnd < 0.05:
        order_status = "cancelled"
    elif rnd < 0.10:
        order_status = "refunded"
    elif rnd < 0.95:
        order_status = "delivered"
    else:
        order_status = "paid"

    promo_code = random.choice(PROMO_CODES)
    currency = "USD"  # keep it simple

    delivery_fee = round(random.uniform(1, 5), 2)
    tip_amount = round(random.choice([0, 0, 0, random.uniform(1, 3)]), 2)

    # Generate between 1 and 8 items per order
    num_items = random.randint(1, 8)
    subtotal = 0.0
    discount = 0.0

    for _ in range(num_items):
        prod_id, standard_price, cost_price = random.choice(products)
        quantity = random.randint(1, 5)
        unit_price = standard_price

        line_subtotal = round(quantity * unit_price, 2)

        # Some line-level discount if promo
        if promo_code and random.random() < 0.5:
            line_discount = round(line_subtotal * random.uniform(0.05, 0.25), 2)
        else:
            line_discount = 0.0

        line_total = round(line_subtotal - line_discount, 2)

        subtotal += line_subtotal
        discount += line_discount

        items_writer.writerow([
            f"ITEM_{order_item_id:09d}", order_id, prod_id,
            quantity, unit_price, line_subtotal,
            line_discount, line_total, created_at.isoformat(sep=" ")
        ])

        order_item_id += 1

    subtotal = round(subtotal, 2)
    discount = round(discount, 2)
    total_amount = round(subtotal - discount + delivery_fee + tip_amount, 2)

    orders_writer.writerow([
        order_id, customer_id, order_datetime.isoformat(sep=" "),
        order_status, payment_method, city, country,
        device_type, promo_code if promo_code else "",
        subtotal, discount, delivery_fee,
        tip_amount, total_amount, currency,
        created_at.isoformat(sep=" "), updated_at.isoformat(sep=" ")
    ])

    if order_status == "delivered":
        delivered_orders.append((order_id, order_datetime, city, country, customer_id))

orders_file.close()
order_items_file.close()

print(f"Generated {NUM_ORDERS} orders and {order_item_id - 1} order items")
print(f"Delivered orders captured for deliveries/marketing: {len(delivered_orders)}")


# ------------------------
# 5. Generate drivers
# ------------------------
drivers = []

with open(os.path.join(DATA_DIR, "drivers.csv"), mode="w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow([
        "driver_id", "first_name", "last_name", "phone_number",
        "city", "country", "vehicle_type",
        "employment_type", "start_date", "end_date"
    ])

    start_drivers = datetime(2021, 1, 1)
    end_drivers = datetime(2025, 10, 31)

    for i in range(1, NUM_DRIVERS + 1):
        driver_id = f"DRV_{i:05d}"
        first_name = fake.first_name()
        last_name = fake.last_name()
        phone_number = fake.msisdn()
        city, country = random.choice(CITIES)
        vehicle_type = random.choice(VEHICLE_TYPES)
        employment_type = random.choice(EMPLOYMENT_TYPES)

        start_date = random_date(start_drivers, end_drivers).date()
        if random.random() < 0.1:
            end_date = random_date(datetime.combine(start_date, datetime.min.time()), end_drivers).date()
        else:
            end_date = ""

        writer.writerow([
            driver_id, first_name, last_name, phone_number,
            city, country, vehicle_type, employment_type,
            start_date.isoformat(), end_date if end_date == "" else end_date.isoformat()
        ])

        drivers.append((driver_id, city, country))

print(f"Generated {NUM_DRIVERS} drivers")


# ------------------------
# 6. Generate warehouses
# ------------------------
warehouses = []

with open(os.path.join(DATA_DIR, "warehouses.csv"), mode="w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow([
        "warehouse_id", "city", "country",
        "latitude", "longitude", "warehouse_name",
        "is_active", "opened_at", "closed_at"
    ])

    start_wh = datetime(2020, 1, 1)
    end_wh = datetime(2025, 10, 31)

    # Distribute warehouses roughly evenly across cities
    for i in range(1, NUM_WAREHOUSES + 1):
        warehouse_id = f"WH_{i:03d}"
        city, country = random.choice(CITIES)
        latitude = round(random.uniform(-35, 35), 6)
        longitude = round(random.uniform(-20, 50), 6)
        warehouse_name = f"{city} Hub {i}"
        opened_at = random_date(start_wh, end_wh).date()
        if random.random() < 0.05:
            closed_at = random_date(datetime.combine(opened_at, datetime.min.time()), end_wh).date()
            is_active = False
        else:
            closed_at = ""
            is_active = True

        writer.writerow([
            warehouse_id, city, country,
            latitude, longitude, warehouse_name,
            int(is_active), opened_at.isoformat(),
            closed_at if closed_at == "" else closed_at.isoformat()
        ])

        warehouses.append((warehouse_id, city, country))

print(f"Generated {NUM_WAREHOUSES} warehouses")


# ------------------------
# 7. Generate deliveries (1 per delivered order)
# ------------------------
with open(os.path.join(DATA_DIR, "deliveries.csv"), mode="w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow([
        "delivery_id", "order_id", "driver_id",
        "pickup_warehouse_id", "delivery_status",
        "pickup_time", "out_for_delivery_time",
        "delivered_time", "cancelled_time",
        "distance_km", "estimated_delivery_minutes",
        "actual_delivery_minutes", "failure_reason"
    ])

    for idx, (order_id, order_datetime, city, country, customer_id) in enumerate(delivered_orders, start=1):
        delivery_id = f"DLV_{idx:07d}"

        # pick a driver and warehouse in same city if possible
        city_drivers = [d for d in drivers if d[1] == city]
        city_warehouses = [w for w in warehouses if w[1] == city]

        if city_drivers:
            driver_id = random.choice(city_drivers)[0]
        else:
            driver_id = random.choice(drivers)[0]

        if city_warehouses:
            pickup_warehouse_id = random.choice(city_warehouses)[0]
        else:
            pickup_warehouse_id = random.choice(warehouses)[0]

        # Delivery times
        pickup_time = order_datetime + timedelta(minutes=random.randint(5, 30))
        out_for_delivery_time = pickup_time + timedelta(minutes=random.randint(5, 20))

        # Distance and times
        distance_km = round(random.uniform(1, 15), 2)
        estimated_minutes = round(random.uniform(20, 60), 2)

        # Actual time: mostly near estimate, sometimes late
        if random.random() < 0.8:
            actual_minutes = round(estimated_minutes + random.uniform(-10, 10), 2)
            actual_minutes = max(actual_minutes, 5.0)
        else:
            actual_minutes = round(estimated_minutes + random.uniform(10, 40), 2)

        delivered_time = out_for_delivery_time + timedelta(minutes=actual_minutes)
        delivery_status = "delivered"
        cancelled_time = ""
        failure_reason = ""

        writer.writerow([
            delivery_id, order_id, driver_id,
            pickup_warehouse_id, delivery_status,
            pickup_time.isoformat(sep=" "), out_for_delivery_time.isoformat(sep=" "),
            delivered_time.isoformat(sep=" "), cancelled_time,
            distance_km, estimated_minutes, actual_minutes, failure_reason
        ])

print(f"Generated {len(delivered_orders)} deliveries")


# ------------------------
# 8. Generate marketing campaigns
# ------------------------
campaigns = []

with open(os.path.join(DATA_DIR, "campaigns.csv"), mode="w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow([
        "campaign_id", "campaign_name", "channel",
        "country", "campaign_start_date", "campaign_end_date",
        "budget_usd", "objective"
    ])

    start_campaigns = datetime(2022, 1, 1)
    end_campaigns = datetime(2025, 10, 31)

    for i in range(1, NUM_CAMPAIGNS + 1):
        campaign_id = f"CMP_{i:04d}"
        channel = random.choice(CAMPAIGN_CHANNELS)
        objective = random.choice(CAMPAIGN_OBJECTIVES)
        city, country = random.choice(CITIES)

        start_date = random_date(start_campaigns, end_campaigns).date()
        end_date = start_date + timedelta(days=random.randint(7, 90))
        budget_usd = round(random.uniform(1_000, 50_000), 2)
        campaign_name = f"{channel.title()} {objective.title()} {i}"

        writer.writerow([
            campaign_id, campaign_name, channel,
            country, start_date.isoformat(), end_date.isoformat(),
            budget_usd, objective
        ])

        campaigns.append((campaign_id, channel, country, start_date, end_date, budget_usd, objective))

print(f"Generated {NUM_CAMPAIGNS} campaigns")


# ------------------------
# 9. Generate campaign attributions
# ------------------------
with open(os.path.join(DATA_DIR, "campaign_attributions.csv"), mode="w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow([
        "order_id", "campaign_id", "attribution_model", "attribution_weight"
    ])

    # Take a subset of delivered orders and assign 1–2 campaigns
    max_attr_orders = min(len(delivered_orders), 400_000)
    attributed_orders = random.sample(delivered_orders, max_attr_orders)

    rows_written = 0

    for order_id, order_datetime, city, country, customer_id in attributed_orders:
        # choose 1 or 2 campaigns
        num_camps = 1 if random.random() < 0.7 else 2
        chosen_campaigns = random.sample(campaigns, num_camps)
        weights = []

        if num_camps == 1:
            weights = [1.0]
        else:
            # simple equal split
            weights = [0.5, 0.5]

        for (campaign_id, channel, camp_country, start_date, end_date, budget_usd, objective), w in zip(chosen_campaigns, weights):
            attribution_model = random.choice(ATTRIBUTION_MODELS)
            writer.writerow([
                order_id, campaign_id, attribution_model, w
            ])
            rows_written += 1

print(f"Generated {rows_written} campaign attribution rows")


# ------------------------
# 10. Generate support tickets
# ------------------------
with open(os.path.join(DATA_DIR, "tickets.csv"), mode="w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow([
        "ticket_id", "customer_id", "order_id",
        "ticket_created_at", "ticket_status",
        "category", "resolution_time_minutes",
        "csat_score", "notes"
    ])

    start_tickets = datetime(2022, 1, 1)
    end_tickets = datetime(2025, 10, 31)

    # we will sample from all customers and delivered orders
    all_order_ids = [o[0] for o in delivered_orders]

    for i in range(1, NUM_TICKETS + 1):
        ticket_id = f"TKT_{i:06d}"
        customer_id, city, country = random.choice(customers)

        # 70% of tickets tied to an order
        if all_order_ids and random.random() < 0.7:
            order_id = random.choice(all_order_ids)
        else:
            order_id = ""

        ticket_created_at = random_date(start_tickets, end_tickets)
        ticket_status = random.choice(TICKET_STATUS)
        category = random.choice(TICKET_CATEGORIES)

        # resolution time: only if closed or pending
        if ticket_status == "closed":
            resolution_time = round(random.uniform(10, 720), 2)  # up to 12 hours
            csat_score = round(random.choice([3, 4, 5]) if random.random() < 0.8 else random.choice([1, 2]), 1)
        elif ticket_status == "pending":
            resolution_time = round(random.uniform(10, 720), 2)
            csat_score = ""
        else:  # open
            resolution_time = ""
            csat_score = ""

        notes = fake.sentence(nb_words=12)

        writer.writerow([
            ticket_id, customer_id, order_id,
            ticket_created_at.isoformat(sep=" "),
            ticket_status, category,
            resolution_time, csat_score, notes
        ])

print(f"Generated {NUM_TICKETS} tickets")

print("Data generation complete.")
