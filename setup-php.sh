#!/usr/bin/env bash
#!/usr/bin/env bash
read -p "Project Name: " pname

default_php="7.3"
read -p "PHP Version [$default_php]: " php
php=${php:-$default_php}

default_wpv="6.5"
read -p "WP Version [$default_wpv]: " wpv
wpv=${wpv:-$default_wpv}

read -p "Import DB: " sqlpath
read -p "Replace URL: " url
current_path=$(pwd)
if [[ -z "$pname" ]]; then
    echo "請輸入不重複專案名稱"
    exit
elif [[ ! -e "$current_path/$pname" ]]; then
    mkdir $current_path/$pname
else
    echo "專案目錄已經存在，請檢查是否已經建立過"
    exit
fi
cd $current_path/$pname
#https://ddev.readthedocs.io/en/latest/users/configuration/config/
ddev config --php-version "$php" --project-type wordpress --project-name "$pname"
ddev start
if [ -n "$wpv" ]; then
    ddev wp core download --version="$wpv" --locale=zh_TW --force
fi
ddev wp core install --url=https://"$pname".ddev.site --title="$pname" --admin_user=admin --admin_password=123456 --admin_email=ddev@some.site --locale=zh_TW
if [ -n "$sqlpath" ]; then
    ddev import-db "$pname" <"$sqlpath"
fi
if [ -n "$url" ]; then
    ddev wp search-replace "$url" https://"$pname".ddev.site
fi
