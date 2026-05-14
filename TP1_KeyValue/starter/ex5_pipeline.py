import redis

r = redis.Redis(host='localhost', port=6379, decode_responses=True)

def bulk_insert_products(r, products: list):
    pipe = r.pipeline()
    for p_id, p_data in products:
        pipe.hset(f"product:{p_id}", mapping=p_data)
    pipe.execute()

def process_order_transactional(r, user_id, product_id, quantity):
    with r.pipeline() as pipe:
        while True:
            try:
                pipe.watch(f"product:{product_id}")
                stock = int(pipe.hget(f"product:{product_id}", "stock") or 0)
                if stock >= quantity:
                    pipe.multi()
                    pipe.hincrby(f"product:{product_id}", "stock", -quantity)
                    pipe.hincrby(f"cart:{user_id}", product_id, quantity)
                    pipe.execute()
                    return True
                else:
                    pipe.unwatch()
                    return False
            except redis.WatchError:
                continue

if __name__ == "__main__":
    r.flushdb()
    products = [
        (1, {"name": "S23", "price": "150000", "stock": "10"}),
        (2, {"name": "iPhone 15", "price": "200000", "stock": "5"})
    ]
    bulk_insert_products(r, products)
    print("Bulk insert done.")
    
    success = process_order_transactional(r, "user:1", 1, 2)
    print(f"Order success: {success}")
    print(f"Stock after: {r.hget('product:1', 'stock')}")
