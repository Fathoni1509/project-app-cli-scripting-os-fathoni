#!/bin/bash

# deklarasi array untuk simpan data siswa
declare -a namaSiswa
declare -a beratSiswa
declare -a tinggiSiswa
declare -a bmiSiswa
declare -a statusSiswa

# function kalkulator BMI
tampilkan_bmi() {
    local nama=$1
    local berat=$2
    local tinggi=$3

    # ubah tinggi badan menjadi meter
    meter=$(echo "scale=2; $tinggi / 100" | bc -l)

    # hitung BMI
    hasil=$(echo "scale=4; $berat / (($meter * $meter))" | bc -l)
    bmiSiswa+=("$hasil")

    # panggil function status untuk lihat status BMI
    status_bmi "$hasil"
    statusSiswa+=("$status")

    # cetak hasil
    echo "Nama Siswa    : $nama" 
    echo "Berat Badan   : $berat kg" 
    echo "Tinggi Badan  : $tinggi cm" 
    echo "BMI           : $hasil" 
    echo "Status BMI    : $status"
}

# function untuk menampilkan status BMI
status_bmi() {
    local bmi=$1

    # kondisional status BMI
    if (( $(echo "$bmi < 18.5" | bc -l) )); then
        status=$(echo -e "\e[33mBerat Badan Kurang\e[0m")
    elif (( $(echo "$bmi >= 18.5 && $bmi <=22.9" | bc -l) )); then
        status=$(echo -e "\e[32mBerat Badan Normal\e[0m")
    elif (( $(echo "$bmi >= 23 && $bmi <=24.9" | bc -l) )); then
        status=$(echo -e "\e[33mBerat Badan Berlebih\e[0m")
    elif (( $(echo "$bmi >= 25 && $bmi <=29.9" | bc -l) )); then
        status=$(echo -e "\e[31mObesitas 1\e[0m")
    else
        status=$(echo -e "\e[31mObesitas 2\e[0m")
    fi
}

# function hitung tiap siswa
tiap_siswa() {
    echo -e "\n\e[32m[[[ Cek BMI Tiap Siswa ]]]"
    echo -e "\e[33m-----------------------------------------------------\e[0m"

    # input nama siswa
    while true; do
        read -p "Masukkan nama siswa/i                              : " nama
        if [[ -n "$nama" ]] && [[ $nama =~ ^[A-Za-z]+([ ][A-Za-z]+)*$ ]]; then
            namaSiswa+=("$nama")
            break
        else 
            echo -e "\e[31mInput nama anda tidak valid\e[0m"
        fi
    done

    # input berat badan siswa
    while true; do
        read -p "Masukkan berat badan siswa (dalam kg, cth: 51.2)   : " berat
            if [[ $berat =~ ^[0-9]+([.][0-9]+)?$ ]] && (( $(echo "$berat > 0" | bc -l) )); then
                beratSiswa+=("$berat")
                break
            else
                echo -e "\e[31mInput harus berupa angka lebih dari 0, gunakan titik (.) untuk menyatakan pecahan\e[0m"
            fi
    done

    # input tinggi badan siswa
    while true; do
        read -p "Masukkan tinggi badan siswa (dalam cm, cth: 155.7) : " tinggi
            if [[ $tinggi =~ ^[0-9]+([.][0-9]+)?$ ]] && (( $(echo "$tinggi > 0" | bc -l) )); then
                tinggiSiswa+=("$tinggi")
                break
            else
                echo -e "\e[31mInput harus berupa angka lebih dari 0, gunakan titik (.) untuk menyatakan pecahan\e[0m"
            fi
    done

    echo -e "\e[33m-----------------------------------------------------\e[0m"

    # tampilkan hasil perhitungan, panggil function tampilkan_bmi
    echo -e "\e[32m[[[ Hasil Perhitungan BMI ]]]\e[0m"
    tampilkan_bmi "$nama" "$berat" "$tinggi"
}

# function seluruh siswa
seluruh_siswa() {
    while true; do
        echo -e "\n\e[32m[[[ Cek BMI Seluruh Siswa ]]]\e[0m"
        read -p "Jumlah siswa yang ingin diperiksa: " jumlah
        if [[ $jumlah =~ ^[0-9]+$ ]]; then
            # looping untuk input siswa satu persatu
            for ((i=0; i<$jumlah; i++)); do
                tiap_siswa
            done
            break
        else
            echo -e "\e[31mInput harus berupa angka bulat!\e[0m\n"
        fi
    done
}

# function untuk menampilkan data keseluruhan
data_semua() {
    local total=0
    local kurang=0
    local normal=0
    local berlebih=0
    local obes1=0
    local obes2=0

    # cek apakah ada data siswa
    if [ ${#namaSiswa[@]} -eq 0 ]; then
        echo -e "\n\e[31m[[[[ Belum ada data siswa ]]]]\e[0m"
        return
    fi

    # hitung rata rata berat badan
    for berat in "${beratSiswa[@]}"; do
        total=$(echo "$total + $berat" | bc)
    done

    local rata=$(echo "scale=2; $total / ${#namaSiswa[@]}" | bc -l)

    # hitung jumlah siswa tiap status
    for s in "${statusSiswa[@]}"; do
        case $s in
            *"Kurang"*) ((kurang++)) ;;
            *"Normal"*) ((normal++)) ;;
            *"Berlebih"*) ((berlebih++)) ;;
            *"Obesitas 1"*) ((obes1++)) ;;
            *"Obesitas 2"*) ((obes2++)) ;;
        esac
    done

    # tampilkan statistik
    echo -e "\n\e[32m[[[ Statistik BMI ]]]\e[0m"
    echo -e "\e[33m-----------------------------------------------------\e[0m"
    echo -e "Jumlah Siswa\t\t\t: ${#namaSiswa[@]}"
    echo -e "Rata-rata Berat Badan\t\t: $rata kg"
    echo -e "Kurang\t\t\t\t: \e[33m$kurang\e[0m"
    echo -e "Normal\t\t\t\t: \e[32m$normal\e[0m"
    echo -e "Berlebih\t\t\t: \e[33m$berlebih\e[0m"
    echo -e "Obesitas 1\t\t\t: \e[31m$obes1\e[0m"
    echo -e "Obesitas 2\t\t\t: \e[31m$obes2\e[0m"
    echo -e "\e[33m-----------------------------------------------------\e[0m"
    
    echo -e "\n\e[32m[[[ Data BMI Seluruh Siswa ]]]\e[0m"
    # looping tampilkan seluruh data siswa
    echo -e "\e[33m-----------------------------------------------------\e[0m"
    for i in "${!namaSiswa[@]}"; do
        echo "Nama Siswa    : ${namaSiswa[$i]}"
        echo "Berat Badan   : ${beratSiswa[$i]} kg"
        echo "Tinggi Badan  : ${tinggiSiswa[$i]} cm"
        echo "BMI           : ${bmiSiswa[$i]}"
        echo "Status        : ${statusSiswa[$i]}"
        echo -e "\e[33m-----------------------------------------------------\e[0m"
    done

}

# program utama
while true; do
    echo -e "\n\e[34m===== Aplikasi Kalkulator BMI Siswa =====\e[0m"
    echo "1. Cek BMI Tiap Siswa"
    echo "2. Cek BMI Seluruh Siswa"
    echo "3. Tampilkan Data Keseluruhan"
    echo "4. Keluar"

    read -p "Pilih menu [1-4]: " menu

    # switch case untuk pemilihan menu
    case $menu in
        1)
            tiap_siswa
            ;;
        2)
            seluruh_siswa
            ;;
        3)
            data_semua
            ;;
        4) 
            echo -e "\n\e[35m///// Terima kasih telah menggunakan aplikasi kami \\\\\ \e[0m"
            exit 0
            ;;
        *)
            echo -e "\e[31mInput Anda tidak valid\e[0m"
            ;;
    esac
done