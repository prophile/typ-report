import re
import sys

pattern = re.compile('^\\\\include\\{build/(.*)\\}$')
patternNon = re.compile('^\\\\include\\{(.*)\\}$')

for line in sys.stdin:
    match = pattern.match(line.strip())
    if match:
        print("report.pdf: build/{0}.tex".format(match.group(1)))
    else:
        match = patternNon.match(line.strip())
        if match:
            print("report.pdf: {0}.tex".format(match.group(1)))

