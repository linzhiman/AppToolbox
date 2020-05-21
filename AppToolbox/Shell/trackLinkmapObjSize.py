import os
import re
import json
import subprocess


def write_html_begin(version):
    if not os.path.exists('./trackLinkmapObjSize/'):
        os.mkdir('./trackLinkmapObjSize/')
    html_file_path = './trackLinkmapObjSize/trackLinkmapObjSize%s.html' % version
    file = open(html_file_path, 'w+')
    file.write('<html><meta http-equiv="Content-Type" content="text/html; charset=utf-8">')
    file.write('<head><title>trackLinkmapObjSize</title></head><body>')
    return file


def write_html_end(file, version):
    html_file_path = './trackLinkmapObjSize/trackLinkmapObjSize%s.html' % version
    file.write('</body></html>')
    file.close()
    subprocess.call(['open', html_file_path])


def write_html_table(file, title, cell_list, color):
    file.write('<p></p>')
    file.write('<table border = "1"><tr style="background-color:%s"><td> %s </td><td> %s </td></tr>' % (color, title, 'byte'))
    for (key, value) in cell_list:
        file.write('<tr><td> %s </td><td> %d </td></tr>' % (key, value))
    file.write('</table>')


def write_html_table_begin(file):
    file.write('<p></p>')
    file.write('<table border = "1">')


def write_html_table_cell(file, title, content, color):
    file.write('<tr style="background-color:%s"><td> %s </td><td> %s </td></tr>' % (color, title, content))


def write_html_table_cell_list(file, cell_list):
    for (key, value) in cell_list:
        file.write('<tr><td> %s </td><td> %d </td></tr>' % (key, value))


def write_html_table_end(file):
    file.write('</table>')


def save_dic_to_json(dic, dic_type, dic_version):
    json_file_path = './trackLinkmapObjSize/trackLinkmapObjSize%s%s.json' % (dic_type, dic_version)
    with open(json_file_path, 'w', encoding='utf-8') as f:
        json.dump(dic, f)


def get_dic_from_json(dic_type, dic_version):
    json_file_path = './trackLinkmapObjSize/trackLinkmapObjSize%s%s.json' % (dic_type, dic_version)
    if not os.path.exists(json_file_path):
        return {}
    with open(json_file_path, 'r', encoding='utf-8') as f:
        file_content = f.read()
        res = json.loads(file_content)
        return res


def sort_to_list(dic):
    return sorted(dic.items(), key=lambda kv: (kv[1], kv[0]), reverse=True)


def write_dic_to_html(file, title, cur_dic, pre_dic):
    add_dic = {}
    remove_dic = {}
    change_dic = {}
    if pre_dic is not None:
        for key, value in pre_dic.items():
            if key in cur_dic:
                if value != cur_dic[key]:
                    change_dic[key] = cur_dic[key] - value
            else:
                remove_dic[key] = value
        for key, value in cur_dic.items():
            if key not in pre_dic:
                add_dic[key] = value

    file.write('<p>%s</p>' % title)
    write_html_table_begin(file)
    write_html_table_cell(file, 'added', 'byte', 'rgb(255,100,83)')
    write_html_table_cell_list(file, sort_to_list(add_dic))
    write_html_table_cell(file, 'removed', 'byte', 'rgb(180,220,16)')
    write_html_table_cell_list(file, sort_to_list(remove_dic))
    write_html_table_cell(file, 'changed', 'byte', 'rgb(238,227,100)')
    write_html_table_cell_list(file, sort_to_list(change_dic))
    write_html_table_cell(file, 'current', 'byte', 'rgb(86,116,254)')
    write_html_table_cell_list(file, sort_to_list(cur_dic))
    write_html_table_end(file)


def do(linkmap_file_path, cur_version, pre_version):
    try:
        file = open(linkmap_file_path, 'r', 1, 'utf8', 'ignore')
        file_lines = file.readlines()
        file.close()

        index_name_dic = {}
        index_size_dic = {}

        # [  0] linker synthesized
        rule_object_files = r'^\[\s*(\d+)\]\s+(.+)'

        # 0x100004EC0	0x00000092	[  4] _main
        rule_symbols = r'^.+\s+(0x\w+)\s+\[\s*(\d+)\]\s+(.+)'

        is_object_files = False
        is_sections = False
        is_symbols = False
        for line in file_lines:
            line = line.replace('\n', '')
            if line == '# Object files:':
                is_object_files = True
                continue
            if line == '# Sections:':
                is_sections = True
                continue
            if line == '# Symbols:':
                is_symbols = True
                continue
            if is_symbols:
                match_obj = re.match(rule_symbols, line)
                if match_obj:
                    symbols_size = int(match_obj.group(1), 16)
                    index_size_dic[match_obj.group(2)] += symbols_size
            elif is_sections:
                continue
            elif is_object_files:
                match_obj = re.match(rule_object_files, line)
                if match_obj:
                    object_path = match_obj.group(2)
                    object_path = object_path[object_path.rfind('/')+1:len(object_path)]
                    index_name_dic[match_obj.group(1)] = object_path
                    index_size_dic[match_obj.group(1)] = 0

        name_size_dic = {}
        for index, size in index_size_dic.items():
            name_size_dic[index_name_dic[index]] = size

        # libATKit.a(ATNotificationUtils.o)
        rule_group = r'(.+)\((.+)\)'

        result_group_size_dic = {}
        result_group_name_size_dic = {}
        for name, size in name_size_dic.items():
            match_obj = re.match(rule_group, name)
            if match_obj:
                group_name = match_obj.group(1)
                result_group_size_dic[group_name] = result_group_size_dic.get(group_name, 0) + size
                result_group = result_group_name_size_dic.get(group_name, {})
                result_group[match_obj.group(2)] = size
                result_group_name_size_dic[group_name] = result_group
            else:
                result_group_size_dic[name] = size

        save_dic_to_json(result_group_size_dic, 'object', cur_version)
        pre_result_group_size_dic = get_dic_from_json('object', pre_version)

        save_dic_to_json(result_group_name_size_dic, 'group', cur_version)
        pre_result_group_name_size_dic = get_dic_from_json('group', pre_version)

        file = write_html_begin(cur_version)
        write_dic_to_html(file, 'object', result_group_size_dic, pre_result_group_size_dic)
        for group_name, group_name_size_dic in result_group_name_size_dic.items():
            pre_group_name_size_dic = pre_result_group_name_size_dic.get(group_name, {})
            write_dic_to_html(file, group_name, group_name_size_dic, pre_group_name_size_dic)
        for group_name, group_name_size_dic in pre_result_group_name_size_dic.items():
            if group_name not in result_group_name_size_dic:
                write_html_table(file, group_name + '(removed)', sort_to_list(group_name_size_dic), 'rgb(180,220,16)')
        write_html_end(file, cur_version)

    except Exception as e:
        print(linkmap_file_path + ":" + e.__str__())


do('./linkmap.txt', '1.1.0', '1.0.0')
