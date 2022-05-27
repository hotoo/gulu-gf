
function! GetPlusCmd(methodName)
  let plus_cmd_func = '\\(^\\|\\s\\)' . a:methodName . '\\s*('
  let plus_cmd_exports = '\\<exports\\.' . a:methodName . '\\s*='
  let plus_cmd = '+/\\(' . plus_cmd_func . '\\)\\|\\(' . plus_cmd_exports . '\\)/'
  " let plus_cmd = '+/\\<' . a:methodName . '\\s*(/ '
  return plus_cmd
endfunction

function! ReplaceProxyPath(fname)
  " Replace root alias name like '@/mode-name' to '<ROOT>/mode-name'
  let filename = substitute(a:fname, '^@\/', '', '')

  " ctx.service:
  " - this.ctx.service.${filePathName}.${methodName}
  " + app/service/${facadeName}.js
  let re_gulu = '\(\(this\.\)\?ctx\.\|this\.\)\?\(service\)\.\([a-zA-Z0-9_\$\.]\+\)\.\([a-zA-Z0-9_\$]\+\)$'

  if matchstr(filename, re_gulu) != ''
    let filePath = substitute(filename, re_gulu, '\3/\4', '')
    let filePath = substitute(filePath, '\.', '/', 'g')

    let methodName = substitute(filename, re_gulu, '\5', '')
    let b:jsgf_plus_cmd = GetPlusCmd(methodName)

    return filePath
  endif

  " app.controller -> app/controller
  let re_controller = '\(\(this\.\)\?app\.\)\?\(controller\?\)\.\([a-zA-Z0-9\._]\+\)\.\(\w\+\)$'
  if matchstr(filename, re_controller) != ''
    let filePath = substitute(filename, re_controller, 'controller/\4', '')
    let filePath = substitute(filePath, '\.', '/', 'g')

    let methodName = substitute(filename, re_controller, '\5', '')
    let b:jsgf_plus_cmd = GetPlusCmd(methodName)

    return './' . filePath
  endif

  return filename
endfunction

" Gulu 的 controller, service 定义文件跳转
function! InitGuluGF()
  let appPath = finddir('app', expand('%:p:h') . ';')
  execute 'setlocal path+=' . appPath
  set includeexpr=ReplaceProxyPath(v:fname)
endfunction

auto FileType javascript,typescript call InitGuluGF()
