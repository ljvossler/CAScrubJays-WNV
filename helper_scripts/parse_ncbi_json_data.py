import json
import os

human_json_dir = "/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/datafiles/diamond/ncbi_info/human"
jay_json_dir = "/xdisk/mcnew/scrubjays_wnv/ljvossler/scrubjays_wnv/datafiles/diamond/ncbi_info/scrubjays"

human_ensmbl_list = []
jay_symbol_list = []

for info_json in os.listdir(human_json_dir):
    with open(info_json, 'r') as j:
        info_json = json.load(j)

    ensmbl = info_json['reports'][0]['gene']['ensembl_gene_ids']
    human_ensmbl_list.append(ensmbl)

for info_json in os.listdir(jay_json_dir):
    with open(info_json, 'r') as j:
        info_json = json.load(j)

    symbol = info_json['reports'][0]['gene']['symbol']
    jay_symbol_list.append(symbol)