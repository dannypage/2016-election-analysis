import random
import datetime
import time
import pytz

import requests

import twitter
import twitter_credentials  # see example_credentials.py


class PinnyTweeter:

    def __init__(self):
        self.sleep_time = 60 * 60
        self.initialize_apis()

    def initialize_apis(self):
        auth_list = [twitter.OAuth( *creds ) for creds in twitter_credentials.twitter_credentials]
        
        self.api_list        = [twitter.Twitter(auth=a) for a in auth_list]
        self.upload_api_list = [twitter.Twitter(auth=a, domain='upload.twitter.com') for a in auth_list]

    def sleep(self):
        time.sleep(self.sleep_time)

    def send_tweet(self, tweet_params):
        api = random.choice(self.api_list)
        api.statuses.update(**tweet_params)

    def send_pinny(self):
        ## Get the current market value from pinny
        dt = datetime.datetime.now().replace(tzinfo=pytz.timezone('US/Eastern'))

        pinny_json = requests.get('https://www.pinnacle.com/webapi/1.15/api/v1/GuestLines/Contest/Politics/2016-Presidential-Election-USA').json()
        pinny_list = pinny_json['Leagues'][0]['Events'][0]['Participants']
        pinny_offer_dict = {el['Name']: self.convert_american_odds_to_prob(el['MoneyLine']) for el in pinny_list}

        pinny_trump_offer = pinny_offer_dict['Donald Trump and all others']
        pinny_clinton_offer = pinny_offer_dict['Hillary Clinton']

        pinny_clinton_bid = 1 - pinny_trump_offer
        pinny_trump_bid = 1 - pinny_clinton_offer

        status = ('Pinny HRC market: {pinny_clinton_bid:>2.0%} – '
                  '{pinny_clinton_offer:>2.0%}        {dt:%H:%M EST}'
                    .format(**locals()))
        self.send_tweet({'status': status})

    @staticmethod
    def convert_american_odds_to_prob(american_odds):
        if american_odds > 100:
            return 100 / (100 + american_odds)
        else:
            return (-1 * american_odds) / (100 - american_odds)

if __name__ == '__main__':
    pinny_tweeter = PinnyTweeter()
    while True:
        pinny_tweeter.send_pinny()
        pinny_tweeter.sleep()
