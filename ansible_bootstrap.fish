#!/usr/bin/fish

source common.fish
set ANSIBLE_HOST_IP "$(hostname -I | cut -d' ' -f1)"
set ANSIBLE_HOST_DN "$(hostname --long)"
set ANSIBLE_PYTHON_INTERPRETER "/usr/bin/python3"

function install_ansible
  if [ -z "$(apt list --installed 2>/dev/null | grep ansible)" ]
    echo_warning '=> Выполняется установка Ansible'
    sudo apt-get install -y ansible &>/dev/null
    if [ -z "$(apt list --installed 2>/dev/null | grep ansible)" ]
      echo_error '=> Возникла ошибка при установке'
      exit 1
    else 
      echo_success '=> Успешно установлено!'
      exit 0
    end
  end
  echo_success "=> Ansible установлен"
end

function add_ansible_host
  set config /etc/ansible/hosts
  if [ ! -f $config ]
    sudo mkdir --parents /etc/ansible
    echo "[servers]
$ANSIBLE_HOST_DN ansible_host=$ANSIBLE_HOST_IP" | sudo tee $config >/dev/null
    echo_success "=> Создан конфигурационный файл "$config
    echo_success "=> Добавлен "$ANSIBLE_HOST_DN" в управляющие хосты"
    return 0
  end

  if grep -q "$ANSIBLE_HOST_DN" $config
    update_value $ANSIBLE_HOST_DN ansible_host=$ANSIBLE_HOST_IP $config
    return 0
  else
    sudo sed -i "s/\[servers\]/& \n$ANSIBLE_HOST_DN ansible_host=$ANSIBLE_HOST_IP/" $config
    echo_success "=> Добавлена "$ANSIBLE_HOST_DN" в управляющие хосты"
  end
end

function set_python_interpreter
  set config /etc/ansible/hosts
  check_line '[all:vars]' $config
  if [ $status -eq 0 ]
    if grep -q ansible_python_interpreter $config
      update_value ansible_python_interpreter $ANSIBLE_PYTHON_INTERPRETER $config
      return 0
    else
      ## sed: -e expression #1, char 49: unknown option to `s'
      sudo sed -i "s@\[all\:vars\]@& \nansible_python_interpreter=$ANSIBLE_PYTHON_INTERPRETER@" $config
      echo_success "=> Добавлен "$ANSIBLE_PYTHON_INTERPRETER" в конфигурацию хостов"
      return 0
    end
  else
    echo "
[all:vars]
ansible_python_interpreter=$ANSIBLE_PYTHON_INTERPRETER" | sudo tee --append $config >/dev/null
    echo_success "=> Добавлен "$ANSIBLE_PYTHON_INTERPRETER" в конфигурацию хостов"
    return 0
  end
end

install_ansible
add_ansible_host
set_python_interpreter
