import os
import re
import subprocess


def make_address(address_item_list):
    address = ''
    for index in range(len(address_item_list)):
        address = address + address_item_list[len(address_item_list) - 1 - index]
    address = address.lstrip('0')
    return address


def get_address_set(command):
    all_lines = subprocess.getoutput(command)
    all_lines = all_lines.splitlines()
    all_set = set()
    for line in all_lines:
        if line.find('\t') != -1:
            # '0000000100014c28\t68 a5 01 00 01 00 00 00 e0 a5 01 00 01 00 00 00 '
            line = line[line.find('\t') + 1: len(line)]
            line_items = line.strip().split(' ')
            # ['68', 'a5', '01', '00', '01', '00', '00', '00', 'e0', 'a5', '01', '00', '01', '00', '00', '00']
            # 10001a568 10001a5e0
            line_items_l = []
            line_items_r = []
            if len(line_items) == 8:
                line_items_l = line_items
            elif len(line_items) == 16:
                line_items_l = line_items[0:8]
                line_items_r = line_items[8:16]
            line_string = make_address(line_items_l)
            if len(line_string) > 0:
                all_set.add(line_string)
            line_string = make_address(line_items_r)
            if len(line_string) > 0:
                all_set.add(line_string)
    return all_set


def get_address_classname_dic(command, out_all_name_dic, out_all_super_dic):
    # Contents of (__DATA,__objc_classlist) section
    # 0000000100014c28 0x10001a568 _OBJC_CLASS_$_ATKitTransformViewController
    # ...
    #     superclass 0x0 _OBJC_CLASS_$_NSObject
    # ...
    # Contents of (__DATA,__objc_classrefs) section
    # 000000010001a2d8 0x0 _OBJC_CLASS_$_UIButton
    all_lines = subprocess.getoutput(command)
    all_lines = all_lines.splitlines()
    rule_classlist = r'^\w+\s0x(\w+)\s_OBJC_CLASS_\$_(.+)'
    rule_superclass = r'^    superclass 0x(\w+) _OBJC_CLASS_\$_(.+)'
    is_in_classlist = False
    last_class_find_super = ''
    for line in all_lines:
        if line == 'Contents of (__DATA,__objc_classlist) section':
            is_in_classlist = True
        elif line == 'Contents of (__DATA,__objc_classrefs) section':
            is_in_classlist = False
            break
        if is_in_classlist:
            match_obj = re.match(rule_classlist, line)
            if match_obj:
                out_all_name_dic[match_obj.group(1)] = match_obj.group(2)
                last_class_find_super = match_obj.group(1)
            else:
                match_obj = re.match(rule_superclass, line)
                if match_obj:
                    if len(last_class_find_super) > 0:
                        if match_obj.group(1) != '0':
                            out_all_super_dic[last_class_find_super] = match_obj.group(1)
                        last_class_find_super = ''


def get_address_selname_dic(command, out_all_name_dic):
    # 		      name 0x100011963 setNotifications:
    # 		     types 0x10001294c v24@0:8@16
    # 		       imp 0x10000d330 -[ATNotificationUtils setNotifications:]
    all_lines = subprocess.getoutput(command)
    all_lines = all_lines.splitlines()
    rule_namelist = r'^\s+name\s0x(\w+)\s(.+)'
    rule_sellist = r'^\s+imp\s0x(\w+)\s(.+)'
    is_in_base_methods = False
    last_address = ''
    for line in all_lines:
        if 'baseMethods 0x' in line:
            is_in_base_methods = True
        elif 'baseProtocols 0x' in line:
            is_in_base_methods = False
        elif is_in_base_methods:
            if len(last_address) == 0:
                match_obj = re.match(rule_namelist, line)
                if match_obj:
                    last_address = match_obj.group(1)
            else:
                match_obj = re.match(rule_sellist, line)
                if match_obj:
                    same_name_list = out_all_name_dic.get(last_address, [])
                    same_name_list.append(match_obj.group(2))
                    out_all_name_dic[last_address] = same_name_list
                    last_address = ''


def find_unused_class(object_file_path):
    all_class_name_dic = {}
    all_class_super_dic = {}
    get_address_classname_dic('otool -o -v %s' % object_file_path, all_class_name_dic, all_class_super_dic)
    # print(all_class_name_dic)
    # print(all_class_super_dic)

    all_class_ref_set = get_address_set('otool -s __DATA __objc_classrefs %s' % object_file_path)
    all_class_super_ref_set = set()
    for class_ref in all_class_ref_set:
        tmp_class_ref = class_ref
        while tmp_class_ref in all_class_super_dic:
            tmp_class_ref = all_class_super_dic[tmp_class_ref]
            all_class_super_ref_set.add(tmp_class_ref)
    # print(all_class_ref_set)
    # print(all_class_super_ref_set)
    all_class_ref_set = all_class_ref_set.union(all_class_super_ref_set)

    all_class_set = get_address_set('otool -s __DATA __objc_classlist %s' % object_file_path)
    # print(all_class_set)

    all_class_unused_set = all_class_set.difference(all_class_ref_set)
    # print(len(all_class_unused_set))
    # print(all_class_unused_set)

    all_unused_name_list = []
    for key in all_class_unused_set:
        all_unused_name_list.append(all_class_name_dic[key])
    print('all_unused_name_list')
    print(len(all_unused_name_list))
    print(all_unused_name_list)


def find_unused_selector(object_file_path):
    all_sel_set = get_address_set('otool -s __DATA __objc_selrefs %s' % object_file_path)
    # print(all_sel_set)
    # print(len(all_sel_set))

    all_sel_name_dic = {}
    get_address_selname_dic('otool -o -v %s' % object_file_path, all_sel_name_dic)
    # print(all_sel_name_dic)
    # print(len(all_sel_name_dic))

    all_same_name_dic = {}
    for address in all_sel_set:
        if address in all_sel_name_dic:
            same_name_list = all_sel_name_dic[address]
            if len(same_name_list) == 1:
                del all_sel_name_dic[address]
            else:
                all_same_name_dic[address] = same_name_list

    all_maybe_unused_sel_name_list = sorted(all_sel_name_dic.items(), key=lambda kv: (kv[1], kv[0]), reverse=True)
    print('all_maybe_unused_sel_name_list')
    print(len(all_maybe_unused_sel_name_list))
    print(all_maybe_unused_sel_name_list)
    all_maybe_used_same_sel_name_list = sorted(all_same_name_dic.items(), key=lambda kv: (kv[1], kv[0]), reverse=True)
    print(len(all_maybe_used_same_sel_name_list))
    print(all_maybe_used_same_sel_name_list)


find_unused_class('./ATKitDemo')
find_unused_selector('./ATKitDemo')

