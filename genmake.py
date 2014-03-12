import re
import sys

pattern = re.compile('^\\\\include\\{build/(.*)\\}$')

for line in sys.stdin:
    match = pattern.match(line.strip())
    if match:
        print("report.pdf: build/{0}.tex".format(match.group(1)))

