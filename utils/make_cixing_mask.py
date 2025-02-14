import unicodedata




def contains_korean(text):
    # 定义韩文字符的Unicode范围
    korean_unicode_ranges = [
        (0xAC00, 0xD7AF),  # 基本韩文字母
        (0x1100, 0x11FF),  # 扩展韩文字母（不包括间隔区域）
        (0x3131, 0x318E),  # 韩文兼容字母和标点
        (0xFFA0, 0xFFDC),  # 半角片假名和半角韩文
    ]

    # 遍历文本中的每个字符
    for char in text:
        # 检查字符是否在韩文字符的Unicode范围内
        if any(start <= ord(char) <= end for start, end in korean_unicode_ranges):
            return True  # 找到韩文字符，返回True

    # 如果没有找到韩文字符，返回False
    return False


import sys
tag=open(sys.argv[1],'r',encoding='utf8').readlines()
word=open(sys.argv[2],'r',encoding='utf8').readlines()
char=open(sys.argv[3],'r',encoding='utf8').readlines()
word_tag=open(sys.argv[4],'w')
word_list=[]
word_sub=[]
for line in word:
    if line =='\n':
        word_list.append(word_sub)
        word_sub=[]
        continue
    word_sub.append(line.split('\t')[1].lower())

assert len(word_list)==len(char)
w_ta=''
for ch,wo,ta in zip(char,word_list,tag):


    if '😖😖😖' in ch:
        ch = ch.replace('😖😖😖','😖 😖 😖')
    if '😭😭😭' in ch:
        ch = ch.replace('😭😭😭', '😭 😭 😭')
    if '～～～' in ch:
        ch = ch.replace('～～～','～ ～ ～')
    if '😩😩😩' in ch:
        ch =ch.replace('😩😩😩','😩 😩 😩')
    if '☆☆☆' in ch:
        ch = ch.replace('☆☆☆','☆ ☆ ☆')
    if '○○😍' in ch:
        ch = ch.replace('○○😍','○ ○ 😍')
    if '😰😰😰😰' in ch:
        ch = ch.replace('😰😰😰😰', '😰 😰 😰 😰')
    if '★´∀｀★' in ch:
        ch = ch.replace('★´∀｀★','★ ´ ∀ ｀ ★')

    if '😞😞😞' in ch:
        ch = ch.replace('😞😞😞','😞 😞 😞')
    if '😊😊😊' in ch:
        ch = ch.replace('😊😊😊', '😊 😊 😊')
    if '💕✨😄' in ch:
        ch = ch.replace('💕✨😄','💕 ✨ 😄')
    if '💛💚💜👍😄' in ch:
        ch = ch.replace('💛💚💜👍😄','💛 💚 💜 👍 😄')
    if '😄😄😊😊' in ch:
        ch = ch.replace('😄😄😊😊','😄 😄 😊 😊')
        
    if '💪🏻💪🏻💪🏻' in ch:
        tag_list = ['0'] * (len(wo)-1)
        tag_list.append('2')
        word_tag.write(" ".join(tag_list) + '\n')
        continue
    if contains_korean(ch.replace('##','')):
        tag_list=['0']*(len(wo)-1)
        tag_list.append('2')
        word_tag.write(" ".join(tag_list) + '\n')
        continue
    ch=ch.strip("\n").split(' ')
    ta=ta.split(' ')[:-1]
    #assert len(ch)==len(ta)
    # if len(ch)==len(wo):
    #     word_tag.write(" ".join(ta)+'\n')
    #     continue

    w_ta=''
    index=0
    match = ''
    length=0
    for c in ch:

        match=match+c.replace('##','').lower()

        length += 1
        if len(match)>len(wo[index]) :

            match_1=match[:len(wo[index])]
            if match_1 == wo[index]:
                if '1' in ta[:length]:
                    w_ta= w_ta+'1'+' '
                else:
                    w_ta = w_ta + '0' + ' '
                match=match[len(wo[index]):]
                index += 1
                ta = ta[length:]
                length = 0
            if match == wo[index]:
                length=1
                if '1' in ta[:length]:
                    w_ta = w_ta + '1' + ' '
                else:
                    w_ta = w_ta + '0' + ' '
                match = ''
                index += 1
                ta = ta[length:]
                length = 0
                continue

            continue


        elif match ==wo[index]:

            if '1' in ta[:length]:
                w_ta= w_ta+'1'+' '
            else:
                w_ta = w_ta + '0' + ' '
            match=''
            index += 1
            ta=ta[length:]
            length=0


    w_ta=w_ta+'2'
    assert len(w_ta.split(' '))==len(wo)+1
    word_tag.write(w_ta+'\n')
    