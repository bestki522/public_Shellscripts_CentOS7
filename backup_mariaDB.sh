
#=====  FUNCTION  =============================================================
#          NAME:  BACKUP MARIA DATABASE
#   DESCRIPTION:  Using Linux mysqldump command
#         USAGE:  Execute the shell without any parameters
#       RETURNS:  RESULT FILE (Dump SQL file)
#        AUTHOR:  IVAN
#==============================================================================

#!/bin/bash
while true;
do
        read -p "Vui long nhap password root cua Mysql Database: " password
        echo "-------------------------------------------------------------"
        mysql -h localhost -u root -p${password} -e"quit" 2>/dev/null
        if [ $? == 0 ];
        then
                break
        else
                echo "Ban da nhap sai password cua root..." && sleep 3
        fi
done

echo "Danh sach database dang ton tai trong he thong: "
echo "------------------------------------------------"
mysql -uroot -p${password} -e 'show databases' -s --skip-column-names
echo "---------------------------------------"

while true;
do
        read -p "Nhap ten database can backup: " dbname
        echo    "------------------------------------" && echo "Dang tra cuu ten database..." && sleep 3
        if ! mysql -uroot -p${password} -e 'show databases' -s --skip-column-names | grep ${dbname} > /dev/null;
        then
                echo "${dbname} khong ton tai! Moi ban nhap dung ten database";
        else
                break;
        fi
done

read -p "Luu lai database voi ten la: " bkname
echo    "------------------------------------"

read -p "Luu lai database voi duong dan la: " bkpath
echo    "-------------------------------------------"

if [ ! -d ${bkpath} ];
then
        echo "Duong dan khong ton tai, ban co muon tao thu muc moi ? Y(y)/N(n)" && read select;
        case ${select} in
        [Yy])
                mkdir -p ${bkpath} && echo "Da tao duong dan ${bkpath}" && echo "Tien hanh tao file backup database" && sleep 3
                mysqldump -uroot -p${password} ${dbname} > ${bkpath}/${bkname}.sql && echo "Da backup thanh cong,ket qua: ${bkpath}/${bkname}.sql"
        ;;
        [Nn])
                echo "Thoat chuong trinh"
        ;;
        *)
                echo "Thoat chuong trinh"
        ;;
        esac
else
        mysqldump -uroot -p${password} ${dbname} > ${bkpath}/${bkname}.sql && echo "Da backup thanh cong,ket qua: ${bkpath}/${bkname}.sql"
fi

exit 0;
