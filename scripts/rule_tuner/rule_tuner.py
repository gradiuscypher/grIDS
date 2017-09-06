import elasticsearch
import argparse
import re


def parse_rule_line(rule_line):
    """
    Parse each rule line and return a dict representation of a rule
    :param rule_line:
    :return: rule dict
    """
    rule_dict = {}
    rule_info = re.search("\((.*)\)", rule_line).group(1)
    msg_sections = rule_info.split(';')

    # Get the rule action
    rule_dict['action'] = rule_line.split()[0]

    # Get the rule headers
    rule_dict['headers'] = rule_line.split("(")[0].replace(rule_dict["action"], "").strip()

    # Get the rest of the rule options
    for section in msg_sections:
        if len(section) > 0:
            # print(repr(section))
            split_section = section.split(':')
            section_key = split_section[0].strip()

            if len(split_section) > 1:
                section_value = split_section[1].strip()

                if "," in section_value:
                    rule_dict[section_key] = [i.strip() for i in section_value.split(',')]
                else:
                    rule_dict[section_key] = section_value
            else:
                rule_dict[section_key] = ""
    return rule_dict


def parse_rules(filename="/etc/suricata/rules/downloaded.rules"):
    """
    :param filename: the rule file to parse
    Parse the rule file to use in reporting
    :return: rule_dict: return a dict of rule_id:rule
    """
    rules_dict = {}
    rule_file = open(filename, 'r')
    for line in rule_file:
        if not line.startswith("#") and line != "\n":
            rule = parse_rule_line(line.strip())
            rules_dict[rule['sid']] = rule
    return rules_dict

if __name__ == '__main__':
    pass
