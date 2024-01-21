import paho.mqtt.client as mqtt
from locust import User, task, between, events
import json
import random
import time

class DriverUser(User):
    wait_time = between(10, 30)

    def __init__(self, environment, *args, **kwargs):
        super().__init__(environment, *args, **kwargs)
        self.client = mqtt.Client()
        self.client.on_publish = self.on_publish
        self.client.connect("192.168.215.2", 1883)
        self.client.loop_start()

    def on_publish(self, client, userdata, mid):
        print("Message Published...")
        # 触发一个成功事件
        self.environment.events.request.fire(request_type="MQTT", name="publish", response_time=0, response_length=0, exception=None)

    @task
    def publish_location(self):
        latitude = -91
        longitude = -181

        latitude += (random.uniform(0, 1) - 0.5) * 0.01
        longitude += (random.uniform(0, 1) - 0.5) * 0.01

        timestamp_send = int(time.time() * 1000)
        payload = json.dumps({
            "latitude": latitude,
            "longitude": longitude,
            "timestamp_send": timestamp_send
        })

        topic = f"reports/driver_sensor_{random.randint(1, 100)}/location"
        self.client.publish(topic, payload)

    def on_stop(self):
        self.client.loop_stop()
        self.client.disconnect()
