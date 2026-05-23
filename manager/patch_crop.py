import re

file_path = "/home/anhiutangerinee/code/KittiSU/manager/app/src/main/java/zako/zako/zako/zakoui/screen/moreSettings/MoreSettings.kt"
with open(file_path, "r") as f:
    content = f.read()

old_crop = """                    putExtra("aspectX", screenWidth)
                    putExtra("aspectY", screenHeight)
                    putExtra("outputX", screenWidth)
                    putExtra("outputY", screenHeight)"""

new_crop = """                    putExtra("aspectX", 16)
                    putExtra("aspectY", 9)
                    putExtra("outputX", screenWidth)
                    putExtra("outputY", (screenWidth * 9) / 16)"""

content = content.replace(old_crop, new_crop)

with open(file_path, "w") as f:
    f.write(content)
