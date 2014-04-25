#!/usr/bin/env python
# -*- encoding: utf-8 -*-

from argparse import ArgumentParser
import os
import sys

def resolve(*parts):
    return os.path.abspath(os.path.join(os.path.dirname(__file__), *parts))


def parse_argv(argv=None):
    if argv is None:
        argv = sys.argv
    parse = ArgumentParser()
    parse.add_argument('dictionary')
    return parse.parse_args(args=argv[1:])


def main(argv=None):
    args = parse_argv(argv=argv)

    accepted = set()
    with open(args.dictionary) as dictionary_file:
        for word in dictionary_file:
            word = word.strip()
            if word.isalpha():
                word = word.lower()
                accepted.add(word)

    source = '\n'.join(sorted(accepted))
    for dst in ['private', 'public']:
        dst = resolve('..', 'src', dst)
        os.makedirs(dst, exist_ok=True)
        dst = os.path.join(dst, 'dictionary.txt')
        with open(dst, 'w') as dst_file:
            dst_file.write(source)

    return 0


if __name__ == '__main__':
    exit(main())

