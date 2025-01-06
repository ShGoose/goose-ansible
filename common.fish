function echo_warning
  echo (set_color yellow)$argv(set_color normal)
end

function echo_success
  echo (set_color green)$argv(set_color normal)
end

function echo_error
  echo (set_color red)'[err]'$argv(set_color normal) >/dev/stderr
end

function update_value
  # параметры функции
  set key $argv[1]
  set value $argv[2]
  set config_file $argv[3]

  # Проверяем существует ли файл
  if [ ! -f $config_file ]
    echo_error "==> Ошибка: файл "(set_color blue)$config_file(set_color red)" не существует."
    return 1
  end

  # Проверяем наличие ключа с учетом различных разделителей
  set pattern "^[ \t]*"$key"[ \t]*([=:])?[ \t]*(.*)\$"
  set found_line $(grep -m 1 -E "$pattern" $config_file)

  # Если ключ найден
  if [ -n "$found_line" ]
    # Извлекаем текущее значение
    set separator $(echo $found_line | sed -E "s/$pattern/\1/")
    set current_value $(echo $found_line | sed -E "s/$pattern/\2/")

    # Сравниваем текущее значение с переданным
    if [ "$current_value" = "$value" ]
      echo_success "==> Значение параметра "(set_color blue)$key(set_color green)" уже равно "(set_color blue)$value(set_color green)". Никаких изменений не требуется."
    else
      # Обновляем значение
      sudo sed -i -E "s/$pattern/$key\1 $value/" $config_file
      echo_warning "==> Значение параметра "(set_color blue)$key(set_color yellow)" обновлено с "(set_color blue)$current_value(set_color yellow)" на "(set_color blue)$value(set_color yellow)"."
    end
  else
    echo_error "==> Параметр "(set_color blue)$key(set_color red)" не найден в файле "(set_color blue)$config_file
    return 2
  end
end

function check_line
  set line $argv[1]
  set file $argv[2]

  if [ ! -f $file ]
    echo_error "==> Ошибка: файл "(set_color blue)$file(set_color red)" не существует."
    return 1
  end

  set found_line $(grep -F "$line" $file)
  if [ -n "$found_line" ]
    echo_success "==> Строка "(set_color blue)$line(set_color green)" присутствует в файле "(set_color blue)$file
    return 0
  else
    echo_warning "==> Строка "(set_color blue)$line(set_color yellow)" отсутствует в файле "(set_color blue)$file
    return 2
  end
end
