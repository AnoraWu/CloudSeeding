import requests
from bs4 import BeautifulSoup as BS
import pandas as pd
import os
import datetime
from time import sleep
import random

os.chdir("/Users/anorawu/Documents/GitHub/CloudSeeding")

def get_weibo(v_keyword, v_start_time, v_end_time, v_result_file):
	"""
	爬取微博搜索结果函数
	:param v_keyword: 搜索关键词
	:param v_start_time: 搜索起始时间
	:param v_end_time: 搜索截止时间
	:param v_result_file: 结果文件名
	:return: None
	"""
	
	for page in range(1, max_page + 1):  # 前1页
		print('开始爬取[从{}到{}],第{}页'.format(v_start_time, v_end_time, page))
		sleep(random.uniform(0, 10))
		# 请求地址
		url = 'https://s.weibo.com/weibo'
		# 请求参数
		params = {
			'q': v_keyword,
			'typeall': 1,
			'suball': 1,
			'timescope': 'custom:{}:{}'.format(v_start_time, v_end_time),
			'Refer': 'g',
			'page': page,
		}
		# 请求头
		h1 = {
			'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
			'accept-encoding': 'gzip, deflate, br',
			'accept-language': 'zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7',
			'cache-control': 'max-age=0',
			'cookie': COOKIE_PC,
			'referer': 'https://s.weibo.com/weibo?q=123',
			'sec-ch-ua': '"Not_A Brand";v="99", "Google Chrome";v="109", "Chromium";v="109"',
			'sec-ch-ua-mobile': '?0',
			'sec-ch-ua-platform': '"macOS"',
			'sec-fetch-dest': 'document', 'sec-fetch-mode': 'navigate',
			'sec-fetch-site': 'same-origin',
			'sec-fetch-user': '?1',
			'upgrade-insecure-requests': '1',
			'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36'}

		# 发送请求
		r = requests.get(url, headers=h1, params=params)
		# 解析数据
		soup = BS(r.text, 'html.parser')
		# 判断结束条件
		if '抱歉，未找到相关结果' in soup.text or '以下是您可能感兴趣的微博' in soup.text:
			print('发现结束标识，退出此时间段循环..')
			break
		item_list = soup.find_all('div', {'action-type': 'feed_list_item'})
		print('本页微博数量:', len(item_list))
		weibo_url_list = [] # 微博链接
		id_list = []  # 微博id
		name_list = []  # 用户昵称
		create_time_list = []  # 发布时间
		text_list = []  # 微博博文
		repost_count_list = []  # 转发数
		comment_count_list = []  # 评论数
		like_count_list = []  # 点赞数
		image_url_list = [] # 图片链接
		# video_url_list = [] # 视频链接
		urls_list = [] #网页链接
		for item in item_list:

			# 微博链接
			if item.find('a',{'@click': True}):
				weibo_url = item.find('a',{'@click': True})['@click']
				url = weibo_url.split("copyurl('")[1].split("')")[0]
			weibo_url_list.append(url)

			# 微博id
			id = str(item.attrs['mid'])
			id_list.append(id)
			# 用户昵称
			name = item.find('p', {'node-type': 'feed_list_content'}).get('nick-name')
			name_list.append(name)
			# 发布时间
			create_time = item.find('div', {'class': 'from'}).text.strip().split('来自')[0].strip()
			print('创建时间: ', create_time)
			create_time_list.append(create_time)
			# 微博博文
			if item.find('p', {'node-type': 'feed_list_content_full'}):
				text = item.find('p', {'node-type': 'feed_list_content_full'}).text.strip()
			else:
				text = item.find('p', {'node-type': 'feed_list_content'}).text.strip()
			text_list.append(text)
			# 转发数
			repost_count = item.find('div', {'class': 'card-act'}).find_all('li')[0].text.strip()
			if repost_count == '转发':
				repost_count = 0
			repost_count_list.append(repost_count)
			# 评论数
			comment_count = item.find('div', {'class': 'card-act'}).find_all('li')[1].text.strip()
			if comment_count == '评论':
				comment_count = 0
			comment_count_list.append(comment_count)
			# 点赞数
			like_count = item.find('div', {'class': 'card-act'}).find_all('li')[2].text.strip()
			if like_count == '赞':
				like_count = 0
			like_count_list.append(like_count)

			# 图片链接
			image = []
			if item.find('div', {'node-type': 'feed_list_media_prev'}):
				image_tags = item.find('div', {'node-type': 'feed_list_media_prev'}).find_all('img')
				if image_tags:
					for img in image_tags:
						image.append(img['src'])
			image_url_list.append(image)

			# # 视频链接
			# if item.find('video'):
			# 	video = item.find('video')['src']
			# else:
			# 	video = '无视频'
			# video_url_list.append(video)

			# 网页链接
			urls = []
			if item.find('p', {'node-type': 'feed_list_content_full'}):
				a_tags = item.find('p', {'node-type': 'feed_list_content_full'}).find_all('a')
				if a_tags:
					for a in a_tags:
						i_tag = a.find('i', class_='wbicon')
						if i_tag and i_tag.text.strip() == 'O':
							urls.append(a['href'])
			elif item.find('p', {'node-type': 'feed_list_content'}):
				a_tags = item.find('p', {'node-type': 'feed_list_content'}).find_all('a')
				if a_tags:
					for a in a_tags:
						i_tag = a.find('i', class_='wbicon')
						if i_tag and i_tag.text.strip() == 'O':
							urls.append(a['href'])
			urls_list.append(urls)

		# 保存数据
		df = pd.DataFrame(
			{
				'微博链接': weibo_url_list,
				'页码': page,
				'微博id': id_list,
				'用户昵称': name_list,
				'发布时间': create_time_list,
				'转发数': repost_count_list,
				'评论数': comment_count_list,
				'点赞数': like_count_list,
				'微博内容': text_list,
				'图片链接': image_url_list,
				'网页链接': urls_list
				# '视频链接': video_url_list
			}
		)

		if os.path.exists(v_result_file):  # 如果文件存在，不再设置表头
			header = False
		else:  # 否则，设置csv文件表头
			header = True
		# 保存csv文件
		df.to_csv(v_result_file, mode='a+', index=False, header=header, encoding='utf_8_sig')
		print('结果保存成功:{}'.format(v_result_file))


def get_latest_datetime_from_csv(v_result_file):
    """从CSV文件中获取最新的时间戳"""
    try:
        df = pd.read_csv(v_result_file)
        if not df.empty:
            df['发布时间'] = pd.to_datetime(df['发布时间'], format='%Y年%m月%d日 %H:%M')
            latest_datetime = df['发布时间'].max()
            return latest_datetime
        else:
            return None
    except FileNotFoundError:
        return None

# 保存文件名
result_file = '微博数据_人工影响天气_14-17.csv'
#  搜索关键词
keyword = '人工影响天气'
# 最大页
max_page = 50
# cookie值 改为自己登录微博账号之后的cookie
COOKIE_PC = 'SINAGLOBAL=2579903780436.4746.1727445568781; ULV=1727445568811:1:1:1:2579903780436.4746.1727445568781:; SUBP=0033WrSXqPxfM725Ws9jqgMF55529P9D9W5QukEsSOyNmALA94RNE55o5JpX5KMhUgL.FoM4Shn4eoMXS0e2dJLoIEXLxKqL1hnL1K2LxKML1h.LBo.LxK-L1K.LBoqLxKqL1KqLB-qLxK-L1-qLB.2t; SCF=AlBMOReBUvICT5u0wVPbCLnXr2HYblJrgoNylYIMlgJuXrObmzKVd5wosPY3AzGkHiznUpzQ2Zzlr8fxfeKOwaA.; SUB=_2A25KDf7QDeRhGeFH71oY8inIzD-IHXVpY34YrDV8PUNbmtANLUf5kW9Newwp35KTyk63nAQ4cP-mR5toJoeVO1Bl; ALF=1731271532; XSRF-TOKEN=baPlExuVXxDpIPtfQuBZbLSb; WBPSESS=NyAZoRytRkRkEvTdNBasMCpcF454xBS481a8B0WCfxGrh0SiHHcZUKE2mCIAo_dIFlco4oRemv5tBGXRY-OG8SFyt9-P3pJkmmuxVs-PhIYwAJRP2hTJAkhdnVfpUKVgfvDJ5nvRT6A7_RnxvYolOw=='
# 设置起始时间
start_time = datetime.datetime(2014, 1, 1, 0)
end_time = datetime.datetime(2017, 12, 31, 0)
latest_datetime = get_latest_datetime_from_csv(result_file)

# 开启爬取
if latest_datetime:
	k = (end_time - latest_datetime).days
	for i in range(0, k + 1):  
		try:
			get_weibo(v_keyword=keyword,
						v_start_time=(latest_datetime + datetime.timedelta(days=i)).strftime('%Y-%m-%d-%H'),
						v_end_time=(latest_datetime + datetime.timedelta(days=i + 1)).strftime('%Y-%m-%d-%H'),
						v_result_file=result_file)
		except Exception as e:
			print(i, '发生异常，继续:', str(e))
else:
	k = (end_time - start_time).days
	for i in range(0, k + 1):  
		try:
			get_weibo(v_keyword=keyword,
						v_start_time=(start_time + datetime.timedelta(days=i)).strftime('%Y-%m-%d-%H'),
						v_end_time=(start_time + datetime.timedelta(days=i + 1)).strftime('%Y-%m-%d-%H'),
						v_result_file=result_file)
		except Exception as e:
			print(i, '发生异常，继续:', str(e))

