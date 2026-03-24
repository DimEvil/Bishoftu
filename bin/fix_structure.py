import os
import re
import shutil

repo_dir = r"c:\Users\dimitri_brosens\Documents\Github\Bishoftu"
episodes_dir = os.path.join(repo_dir, "_episodes")
assets_img_dir = os.path.join(repo_dir, "assets", "img")
fig_dir = os.path.join(repo_dir, "fig")

# 1. Rename episodes sequentially
episode_files = [f for f in os.listdir(episodes_dir) if re.match(r'^\d', f) and f.endswith('.md')]

def get_num(f):
    m = re.match(r'^(\d+(?:\.\d+)?)', f)
    return float(m.group(1)) if m else 999
    
episode_files.sort(key=get_num)
rename_map = {}

print("Renaming episodes...")
for i, f in enumerate(episode_files, 1):
    new_name = f"{i:02d}-{re.sub(r'^\d+(?:\.\d+)?-', '', f)}"
    if new_name != f:
        rename_map[f] = new_name
        os.rename(os.path.join(episodes_dir, f), os.path.join(episodes_dir, new_name))
        print(f"Renamed: {f} -> {new_name}")

# 2. Move content images from assets/img to fig/
theme_icons = [
    "swc-icon-blue.svg", "swc-logo-blue.png", "swc-logo-white.png", "swc-logo-white.svg",
    "dc-icon-black.svg", "dc-logo-black.svg",
    "lc-icon-black.png", "lc-icon-black.svg", "lc-logo-black.png", "lc-logo-black.svg",
    "cp-logo-blue.svg", "carpentrieslab.svg", "incubator-logo-blue.svg"
]

moved_items = []
print("\nMoving images...")
if os.path.exists(assets_img_dir):
    for f in os.listdir(assets_img_dir):
        if f in theme_icons:
            continue
        src = os.path.join(assets_img_dir, f)
        dst = os.path.join(fig_dir, f)
        
        try:
            if not os.path.exists(dst):
                shutil.move(src, dst)
            else:
                if os.path.isdir(src):
                    for sub in os.listdir(src):
                        sub_src = os.path.join(src, sub)
                        sub_dst = os.path.join(dst, sub)
                        if not os.path.exists(sub_dst):
                            shutil.move(sub_src, sub_dst)
                    os.rmdir(src)
                else:
                    os.remove(src) # Clean up if it already exactly exists in fig/
            moved_items.append(f)
            print(f"Moved/Processed: {f}")
        except Exception as e:
            print(f"Error moving {f}: {e}")

# 3. Update all links in Markdown and HTML files
print("\nUpdating links...")
def update_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as file:
            content = file.read()
    except UnicodeDecodeError:
        return # Skip binary files

    new_content = content
    # Update episode links
    for old_f, new_f in rename_map.items():
        old_base = old_f.replace('.md', '')
        new_base = new_f.replace('.md', '')
        new_content = new_content.replace(f"../{old_base}/", f"../{new_base}/")
        new_content = new_content.replace(f"{old_base}.html", f"{new_base}.html")
    
    # Update image links
    for item in moved_items:
        new_content = new_content.replace(f"assets/img/{item}", f"fig/{item}")
        
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as file:
            file.write(new_content)
        print(f"Updated links in: {filepath}")

for root_dir, dirs, files in os.walk(repo_dir):
    if ".git" in root_dir or ".Rproj.user" in root_dir:
        continue
    for f in files:
        if f.endswith('.md') or f.endswith('.html'):
            update_file(os.path.join(root_dir, f))

print("\nStructure fixing completed successfully.")
