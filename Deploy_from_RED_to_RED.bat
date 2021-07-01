@ECHO OFF
REM ---------------------------------------------------------------------------
REM -
REM - Name:    Sample RED to RED Deployment
REM -
REM ---------------------------------------------------------------------------
REM - CHANGE HISTORY:
REM - Date     Initials Notes
REM - -------- -------- -------------------------------------------------------
REM - 20210510 PC       Initial version
REM ---------------------------------------------------------------------------
REM - Set variables values
REM - General
REM ---------------------------------------------------------------------------
SET EXE_DIR="C:\Program Files\WhereScape\RED"
SET APP_DIR="C:\Users\Glenn\Files\Wherescape\Applications"
SET APP_NUM="Demo"
SET APP_VER="Deploy"
SET RES_NUM="Res_Demo"
SET RES_VER="Deploy"
SET RED_ARC=64

REM ---------------------------------------------------------------------------
REM - Source Details
REM ---------------------------------------------------------------------------
SET SRC_DSN="Dev"
SET SRC_DBN="Dev"
SET SRC_USR=""
SET SRC_PWD=""
SET SRC_GRP="Releases"
SET SRC_PRJ="001"

REM ---------------------------------------------------------------------------
REM - Target Details
REM ---------------------------------------------------------------------------
SET RED_USR=""
SET TGT_DSN="Test"
SET TGT_DBN="Test"
SET TGT_USR=""
SET TGT_PWD=""
SET LOG_FIL=%APP_DIR%%APP_NUM%_%APP_VER%.log

REM ---------------------------------------------------------------------------
REM - Work out location of executables
REM ---------------------------------------------------------------------------
SET MED_EXE="%EXE_DIR:"=%\med.exe"
SET RED_CLI="%EXE_DIR:"=%\redcli.exe"

REM ---------------------------------------------------------------------------
REM - Handle Group / Project / All options
REM ---------------------------------------------------------------------------
IF "%SRC_GRP:"=%" NEQ "" (
   SET EXP_ARG=' --group-name "%SRC_GRP:"=%"'
   SET SRC_MSG='with the contents of Group %SRC_GRP:"=%'
   SET GIT_PRJ=%SRC_GRP%
) ELSE (
   IF  "%SRC_PRJ:"=%" NEQ "" (
      SET EXP_ARG=' --project-name ^"%SRC_PRJ:"=%^"'
      SET SRC_MSG='with the contents of Project %SRC_PRJ:"=%'
      SET GIT_PRJ=%SRC_PRJ%
   ) ELSE (
      SET EXP_ARG=' --deploy-all'
      SET SRC_MSG='with all objects'
      SET GIT_PRJ="ALL"
   )
)

REM ---------------------------------------------------------------------------
REM - Handle Source and Target User/PWD options
REM ---------------------------------------------------------------------------
IF  "%SRC_USR:"=%" NEQ "" (
   SET SRC_ARG=' --meta-user-name %SRC_USR% --meta-password "%SRC_PWD:"=%" '
) ELSE (
   SET SRC_ARG=''
)

IF  "%TGT_USR:"=%" NEQ "" (
   SET TGT_ARG=' --meta-user-name %TGT_USR% --meta-password "%TGT_PWD:"=%" '
) ELSE (
   SET TGT_ARG=''
)

REM ---------------------------------------------------------------------------
REM - Create the deployment application from the source repository
REM ---------------------------------------------------------------------------
ECHO Creating Deployment application %APP_NUM:"=% %APP_VER:"=% %SRC_MSG:'=% from %SRC_DSN:"=% ..
%MED_EXE% --create-deploy-app --meta-dsn %SRC_DSN% --meta-dsn-arch %RED_ARC% --meta-database %SRC_DBN% %SRC_ARG:'=% --output-dir %APP_DIR% --app-number %APP_NUM% --app-version %APP_VER% %EXP_ARG:'=% 

REM ---------------------------------------------------------------------------
REM - GIT integration !! NB: NOT TESTED !!
REM ---------------------------------------------------------------------------
REM IF NOT EXIST "%APP_DIR:"=%\ProjectLock.txt" (
REM    git -C %APP_DIR% pull
REM    git -C %APP_DIR% add %APP_DIR%
REM    git -C %APP_DIR% commit -a -m "Checking in deployment packages for %GIT_PRJ% 'Commit %APP_NUM:"=% %APP_VER:"=%'" | Out-file "%APP_DIR:"=%\deploylog_%APP_NUM:"=%_%APP_VER:"=%.log"
REM    git -C %APP_DIR% push -u origin
REM    git -C %APP_DIR% log -1 | Out-file "%APP_DIR:"=%\commitlog_%APP_NUM:"=%_%APP_VER:"=%.log"
REM )

REM ---------------------------------------------------------------------------
REM - Create 'restore point' application based on objects about to be loaded.
REM ---------------------------------------------------------------------------
ECHO Creating Restore Point application %RES_NUM:"=% %RES_VER:"=% from %TGT_DSN:"=% ..
%MED_EXE% --create-deploy-app --meta-dsn %TGT_DSN% --meta-dsn-arch %RED_ARC% --meta-database %TGT_DBN% %TGT_ARG:'=% --output-dir %APP_DIR% --app-number %RES_NUM% --app-version %RES_VER% --app-file-name "%APP_DIR:"=%\app_id_%APP_NUM:"=%_%APP_VER:"=%.wst"

REM ---------------------------------------------------------------------------
REM - Deploy the application to the target repository
REM ---------------------------------------------------------------------------
ECHO Deploying application %APP_NUM:"=% %APP_VER:"=% into %TGT_DSN:"=% ..
%RED_CLI% deployment deploy --meta-dsn %TGT_DSN% --meta-dsn-arch %RED_ARC% %TGT_ARG:'=% --app-number %APP_NUM% --app-version %APP_VER% --app-directory %APP_DIR% --red-user-name %RED_USR% > %LOG_FIL% 2>&1

ECHO Completed Successfully
