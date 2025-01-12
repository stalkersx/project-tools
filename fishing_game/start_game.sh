#!/bin/bash

# variabel
declare -a ikan trash1 trash2 bait jaring
declare -g umpan time_umpan

# ikan
ikan[0]="Ikan Gabus"
ikan[1]="Ikan Toman"
ikan[2]="Udang"
ikan[3]="Ikan Tuna"
ikan[4]="Ikan Pari"
ikan[5]="Lofster"
ikan[6]="Kepiting"
ikan[7]="Ikan Betok"
ikan[8]="Ikan Tapa"
ikan[9]="Kerang"
ikan[10]="Ikan Baong"
ikan[11]="Belut"
ikan[12]="Ikan Lele"

# trash1
trash1[0]="Anda Mengukur Berat Ikan"
trash1[1]="Ikan Besar Menggigit"
trash1[2]="Anda Mendapatkan Botol Bekas"
trash1[3]="Kail Anda Tersangkut"
trash1[4]="Pancing Anda Rusak"
trash1[5]="Anda Mendapatkan Kayu Kecil"
trash1[6]="Anda Mendapatkan Kaleng Bekas"
trash1[7]="Anda Mandapatkan Popok Bayi"
trash1[8]="Benang Anda Kusut"
trash1[9]="Sepertinya Ikan Besar Menggigit"

# trash2
trash2[0]="Namun Tak Sengaja Ikan Terlepas"
trash2[1]="Namun Terlepas"
trash2[2]="Lalu Membuangnya"
trash2[3]="Gagal Mendapatkan Tangkapan"
trash2[4]="Kemudian Mengantinya"
trash2[5]="lalu Melemparkan Dengan Kesal"
trash2[6]="Kemudian Membuangnya"
trash2[7]="Anda Tertawa Dan Membuangnya"
trash2[8]="Dan Anda Kesal Memukul Tanah"
trash2[9]="Eh Rupanya Sepatu Bekas"

# umpan
bait[0]="Cacing"
bait[1]="Kepompong"
bait[2]="Ulat"
bait[3]="Daging"
bait[4]="Siput"
bait[5]="Roti"
bait[6]="Capung"
bait[7]="Ikan Buatan"
bait[8]="Serangga"

run_text(){
    if [ "$1" ];then
        j_text1=$(expr length "$2")
        n=0
        while [[ $j_text1 -ge $n ]];do
            gchar=${2:$n:1}
            text1+=$gchar
            clear
            player $1 "$text1"
            ((n++))
            sleep 0.1s
        done
    else
        clear; player $1
    fi

    if [ "$3" ];then
        j_text2=$(expr length "$3")
        n=0
        while [[ $j_text2 -ge $n ]];do
            gchar=${3:$n:1}
            text2+=$gchar
            clear
            player $1 "$text1" "$text2"
            ((n++))
            sleep 0.1s
        done
    fi

    if [ "$4" ];then
        j_text3=$(expr length "$4")
        n=0
        while [[ $j_text3 -ge $n ]];do
            gchar=${4:$n:1}
            text3+=$gchar
            clear
            player $1 "$text1" "$text2" "$text3"
            ((n++))
            sleep 0.1s
        done
    fi
    unset text1 text2 text3
}

player(){
    if [[ $1 == "start" ]];then
        echo -e "
             .
     _      /:\t\t$2
    (&)    / :\t\t$3
     |__  /  :\t\t$4
     |\ \&.  :
     | '/    *
     |
    | |
    | |
-------------|\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    elif [[ $1 == "wait" ]];then
        echo -e "
             .
     _      / '.\t$2
    (&)    /    '.\t$3
     |__  /       '.\t$4
     |\ \&.         '.
     | '/             '.
     |                  '.
    | |                   '.
    | |                     '.
-------------|\~~~~~~~~~~~~~~~'~~~~~~~~~~~~~~~~~"
    elif [[ $1 == "finish" ]];then
        echo -e "

     _\t\t$2
    (&)\t\t$3
 .   |__\t$4
 |'. |\ \\
 |  '|*<|$<
 |   |   
 &. | |
 |  | |
-------------|\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    fi
}

masuk_jaring(){
    if [ "$2" ] && [ "$3" ] && [ "$4" ];then
        run_text "finish" "$2" "$3" "$4"
    fi
    read -p "[1]simpan [2]lepaskan --> " inp
    if [[ $inp == "1" ]];then
        t_ikan=${#jaring[@]}
        t_ikan=$(($t_ikan+1))
        jaring[$t_ikan]="$1"
    elif [[ $inp == "2" ]];then echo
    else
        masuk_jaring "$1" "Pilih Angka" "Untuk Menyimpan Ikan $1" "Atau lepaskan"
    fi
}

fishing(){
    ji=${#ikan[@]}
    dpt=$((RANDOM % $ji + 0))
    tm=$(date | awk '{print $4}')
    tm=${tm: -1:1}
    kilo=$(($tm*133*$dpt/3%20))
    if [[ $kilo -ge 7 ]];then
        kilo=$(($kilo*3))
    elif [[ $kilo -ge 10 ]];then
        kilo=$(($kilo*5))
    fi
    run_text "wait" "Menunggu Ikan"
    sleep "${tm}s"
    run_text "wait" "Umpan Digigit"
    sleep 1.5s
    run_text "wait" "Menggulung Benang"
    sleep 3s
    if [[ $kilo == 0 ]];then
        kg="Bayi nya"
    else
        kg="$kilo Kg"
    fi

    jm=$(($jm+1))
    if [[ $jm -eq $time_umpan ]];then
        unset jm umpan time_umpan
        run_text "wait" "Umpan Anda Habis" "Ikan Berhasil Meloloskan Diri"
        sleep 4s
    elif [[ $jm -ge $((tm*2)) ]];then
        run_text "wait" "${trash1[tm]}" "${trash2[tm]}"
        sleep 4s
    else
        run_text "finish" "Anda Mendapatkan ${ikan[dpt]} $kg" "Menggunakan Umpan $umpan"
        masuk_jaring "${ikan[dpt]} $kg"
    fi
}

peralatan(){
    if [[ $1 -eq 1 ]];then clear
        echo "-----------------"
        for n in ${!bait[@]};do
            echo " $n. ${bait[n]}"
        done
        echo "-----------------"
        read -p "Pilih Umpan Anda --> " ump
        for n1 in ${!bait[@]};do
            if [[ $ump == "$n1" ]];then
                n3=$n1
            fi
        done
        if [ "$n3" ];then
            umpan=${bait[n3]}
            time_umpan=$(date | awk '{print $4}')
            time_umpan=${time_umpan: -1:1}
            if [[ $time_umpan -eq 0 ]];then
                time_umpan=$(($time_umpan+2))
            else
                time_umpan=$(($time_umpan*2))
            fi
        else
            peralatan 1
        fi
    elif [[ $1 -eq 2 ]];then clear
        echo "------------------------"
        if [[ ${#jaring[@]} -eq 0 ]];then
            echo "0. jaring kosong"
        fi
        for n in ${!jaring[@]};do
            echo " $n. ${jaring[n]}"
        done
        echo "------------------------"
        read -p "[q]memancing --> " ump
        if [[ $ump == "q" ]];then
            echo
        else
            peralatan 2
        fi
    fi
}

# menu
run_text "start" "Selamat Datang"
while [ true ];do
    read -p "[1]lempar [2]umpan [3]jaring [q]pulang --> " inp
    if [[ $inp == "q" ]];then break
    elif [[ $inp == "1" ]];then
        if [ -z "$umpan" ];then
            run_text "start" "Anda Belum Memasang Umpan"
        else
            fishing 2
            run_text "start"
        fi
    elif [[ $inp == "2" ]];then
        peralatan 1
        run_text "start" "Anda Memasang Umpan $umpan"
    elif [[ $inp == "3" ]];then
        peralatan 2
        run_text "start" "Ayo Memancing Lagi"
    else
        run_text "start" "Pilih Angka Untuk Memancing"
    fi
done