import sys
import requests
import json

data = sys.argv[1]

name = sys.argv[2]

expiretime = sys.argv[3]

expireday = sys.argv[4]

usermobile = {}
usermobile["mobile"] = data

umobile = json.dumps(usermobile)
gettokenurl = "https://api.dingtalk.com/v1.0/oauth2/accessToken"

appinfo = "{\n\t\"appKey\":\"ding1ccznic8qevumdry\",\n\t\"appSecret\":\"M20Da6rYXFtsn0t-81ixEHNXp1O_ThvIFV2Axc_8Xqddj_nFIydVLix4A9P28mf3\"\n}"
headers = {
    'content-type': "application/json",
    'cache-control': "no-cache",
    'postman-token': "8524eeeb-bc48-6fe3-167e-35c8da2fdb3f"
    }

response = requests.request("POST", gettokenurl, data=appinfo, headers=headers)

a=response.text.split(":")
b=a[2]
c=b[1:-2:1]

getuserid = "https://oapi.dingtalk.com/topapi/v2/user/getbymobile"

querystring = {"access_token":c}

headers2 = {
    'content-type': "application/json",
    'cache-control': "no-cache",
    'postman-token': "a1aa1382-6731-d1b4-d488-ba30e289c754"
    }

response = requests.request("POST", getuserid, data=umobile, headers=headers2, params=querystring)

#print(response.text)
#print(type(response.text))
d=response.text.split(",")
#print(d)
#print(type(d))
e=d[2]

f=e.split("\"")

g=f[5]

data1={}
data1["userid_list"]=g
#print(data1)

url1 = "https://oapi.dingtalk.com/topapi/message/corpconversation/asyncsend_v2"


#print(querystring)
text="您好" + name + "，您的ldap密码将于" + expiretime + "过期，" + "有效期剩余" + expireday + "天，请尽快访问" + "http://ssp.super-chameleon.com:9090" + "，修改您的ldap密码，以免影响登录内部业务系统！"
payload1 = {
	"agent_id":1680792395,
	"msg":{
		"msgtype":"text",
		"oa":{
			"body":{
				"content":text
			}
		},
		"text":{
			"content":text
		}

	},
}
payload1.update(data1)

#print(type(payload1))
#print(payload1)
payload2 = json.dumps(payload1)
headers = {
    'content-type': "application/json",
    'cache-control': "no-cache",
    'postman-token': "cdc6c715-02af-7d03-601b-2f101b531405"
    }

response = requests.request("POST", url1, data=payload2, headers=headers, params=querystring)

print(response.text)