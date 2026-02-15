#!/usr/bin/env python3
import re
import os
import glob

def fix_with_opacity(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Replace .withOpacity(value) with .withValues(alpha: value)
    # This regex matches .withOpacity( followed by any expression, then )
    pattern = r'\.withOpacity\('
    replacement = r'.withValues(alpha: '

    if pattern in content:
        # Simple replacement for straightforward cases
        new_content = content.replace('.withOpacity(', '.withValues(alpha: ')

        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        return True
    return False

def main():
    lib_path = 'lib'
    dart_files = glob.glob(f'{lib_path}/**/*.dart', recursive=True)

    fixed_count = 0
    for file_path in dart_files:
        if fix_with_opacity(file_path):
            fixed_count += 1
            print(f'Fixed: {file_path}')

    print(f'\nTotal files fixed: {fixed_count}')

if __name__ == '__main__':
    main()
