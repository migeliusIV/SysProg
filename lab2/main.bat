@ECHO off

REM Устанавливаем кодировку консоли в utf-8
chcp 65001

REM Проверка наличия параметров командной строки
IF "%1"=="" (
    ECHO Ошибка. Не указан первый параметр - имя файла справки.
    PAUSE >NUL
    EXIT /B 1
)

IF "%2"=="" (
    ECHO Ошибка. Не указан второй параметр - необходимость очистки экрана.
    PAUSE >NUL
    EXIT /B 1
)

REM Присвоение параметров переменным
SET helpfile=%1
SET clear=%2

REM Проверка значения параметра очистки экрана
IF /I "%clear%"=="yes" (
    CLS
    ECHO %clear%
) ELSE (
    IF /I "%clear%" NEQ "no" (
        ECHO Ошибка. Не распознан второй параметр.
        PAUSE >NUL
        EXIT /B 1
    )
)

GOTO menu
:menu
ECHO.
ECHO    ===== Меню ===== 
ECHO.
ECHO 1.  Выполнить действие 1 (заглушка)
ECHO 2.  Выполнить действие 2 (заглушка)
ECHO 3.  Команда по варианту (CD)
ECHO 4.  Вывести информацию о системе
ECHO 5.  Вывести справку о программе
ECHO 6.  Выход
ECHO.

REM SET /P ВЫБОР=Введите пункт меню:

CHOICE /C 123ABC /M "Выберите пункт меню: "

IF ERRORLEVEL 6 GOTO exiting   REM .
IF ERRORLEVEL 5 GOTO help      REM .
IF ERRORLEVEL 4 GOTO systeminf REM .
IF ERRORLEVEL 3 GOTO action3   REM .
IF ERRORLEVEL 2 GOTO action2   REM .
IF ERRORLEVEL 1 GOTO action1   REM Выход из программы

ECHO Неверный пункт меню!
PAUSE >NUL
GOTO menu

:action1
REM Действие 1 - болванка
ECHO Выполняем действие 1
ECHO Продолжаем...
PAUSE >NUL
GOTO menu


:action2
REM Действие 2 - болванка
ECHO Выполняем действие 2
ECHO Продолжаем...
PAUSE >NUL
GOTO menu

:action3
REM Действие по варианту
ECHO Команда по варианту
CD
ECHO Нажмите любую клавишу для возврата в меню...
PAUSE >NUL
GOTO menu

:systeminf
REM Информация о системе
SYSTEMINFO
ECHO Нажмите любую клавишу для возврата в меню...
PAUSE >NUL 
GOTO menu

:help
REM Вызов справки из внешнего файла
CALL "%helpfile%"
ECHO Нажмите любую клавишу для возврата в меню...
PAUSE >NUL 
GOTO menu

:exiting
REM Выход из программы
CLS
ECHO Программа завершена.
EXIT /b 0
