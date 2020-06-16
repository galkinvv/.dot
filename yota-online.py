#!/usr/bin/python3

good_bs = ['BD2AF']
usable_slow_bs = ['BE2E6']
import time
import urllib.request
def get_yota_url(suffix):
	try:
		with urllib.request.urlopen("http://10.0.0.1/"+suffix, timeout=5) as req:
			return req.readlines()
	except Exception:
		return []

def get_base_station():
	prefix = b"3GPP.eNBID="
	for line in get_yota_url("status"):
		if line.startswith(prefix):
			return line[len(prefix):].strip().decode('ascii')
	return ""

def reconnect_and_get_new_bs():
	get_yota_url("cmd?action=disable-connect")
	get_yota_url("cmd?action=enable-connect")
	for i in range(400):
		bs = get_base_station()
		if bs: return bs
		time.sleep(0.05)
	return ""

bs = get_base_station()
had_connection = False
while True:
	if bs in good_bs:
		had_connection = True
		time.sleep(2)
		bs = get_base_station()
	else:
		if had_connection and bs in usable_slow_bs:
			time.sleep(10) #keep internet woking for some time
		print(f"Current bs is {bs}, reconnecting")
		bs = reconnect_and_get_new_bs()
		print(f"New bs is {bs}")

