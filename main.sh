# /usr/local/bin/python3

import sys, requests, re, argparse, json

flock_api = 'https://api.flock.co/v1/'

URL_sendMs = f'{flock_api}chat.sendMessage'
URL_gr_list = f'{flock_api}channels.list'
URL_us_list = f'{flock_api}channels.listMembers'

tokens = {
    'own': '*token_here*',
    'bot': '*token_here*'
}

choice = ['bil', 'conc', 'tech', 'test']


groups = {
    choice[3]: 'g:token_group',
    choice[1]: 'g:token_group',
    choice[0]:  'g:token_group',
    choice[2]: 'g:token_group'
}


my_id = 'u:id_in_flock'


def snd_msg_test(param, msg, mentions):
    men = []
    men.append(mentions)
    payload = {'token': tokens['bot'], 'to': groups[param], 'flockml': msg, 'onBehalfOf': my_id,
               'notification': 'I\'ve completed your request.', 'mentions': f'{men}'}
    a = requests.post(url=URL_sendMs, data=payload)
    print(a.text)
    print(a.content)

def get_cs_name(gr, cs_name, mesage):
    survs = []
    n = 0
    num = 0
    if gr not in choice:
        sys.exit('The group is not known')

    gru = {'token': tokens['own'], 'channelId': groups[gr], 'showPublicProfile': 'true'}

    response = requests.post(url=URL_us_list, data=gru)
    users = json.loads(response.text)
    pat = re.compile(f'^{cs_name}')
    for chan in users:
        c = chan['publicProfile']
        k = c.get('firstName')
        if pat.match(k):
            n = n + 1
            survs.append(c)
    if n > 1:
        print('There were several users found.')
        for i in survs:
            print(f'{num} -> {i["lastName"]}')
            num = num + 1

        surname = str((input('Please specify surname: ')))
        pattern = re.compile(f'^{surname}')
        for l in survs:
            print(l['firstName'])
            if pattern.match(l['lastName']):
                part = f'<user userId="{l["id"]}">{l["firstName"]}</user>'

                fin_mes = f'{part} {mesage}'

                snd_msg_test(gr, fin_mes, l["id"])
                break
            else:
                print('No such user')
                sys.exit(2)
    else:
        part = f'<user userId="{c["id"]}">{c["firstName"]}</user>'
        fin_mes = f'{part} {mesage}'
        snd_msg_test(gr, fin_mes, c["id"])

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-m', help=f'Define mode the script will use: {choice[0]}, {choice[1]}, {choice[2]}, {choice[3]}', choices=choice)
    parser.add_argument('-p', help='Name of CS to ping in conf')
    parser.add_argument('-t', help='ID of the related ticket')
    parser.add_argument('-l', help='the link to the related ticket in Kayako')
    parser.add_argument('-u', help='NC username of the customer')
    parser.add_argument('-f', help='The full path to the related file')
    parser.add_argument('-b', help='The link to the packed backup file')
    args = parser.parse_args()

    tick_link = args.l
    tick_id = args.t
    link = args.b
    nc_un = args.u
    file = args.f

    msg_body = {
        choice[3]: f'The <a href="{tick_link}"><strong>{tick_id}</strong></a> ticket\'s been processed.',
        choice[1]: f'The <a href="{tick_link}"><strong>{tick_id}</strong></a> ticket\'s been processed.',
        choice[2]: f'The file\'s been restored to <strong>{file}</strong>.',
        choice[0]: f'The <a href="{link}">backup</a> for <strong>{nc_un}</strong> has been generated.'
    }


    if args.m == choice[0]:
        if not link or not nc_un: sys.exit('Not enough arguments for bil')
    elif args.m == choice[1] or args.m == choice[3]:
        if not tick_link or not tick_id: sys.exit('Not enough arguments')
    elif args.m == choice[2]:
        if not file: sys.exit('Not enough arguments for tech')

    get_cs_name(args.m, args.p, msg_body[args.m])


if __name__ == "__main__":
   main()

