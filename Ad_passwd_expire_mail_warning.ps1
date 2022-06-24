Import-Module Activedirectory
$alladuser=get-aduser -searchbase "CN=Users,DC=volcano-forece,DC=com" -filter *  | %{$_.sAMAccountName}
#上面的“ou=***,dc=***,dc=***” 根据自己域结构实际情况填写
$userlist = @()

echo $alladuser#显示所有用户

#echo $userlist
$itmag = "it@volcano-force.com" #IT管理员的邮件地址

function sendmail($mailaddr,$body) #定义发送邮件的方法
{  
$msg=New-Object System.Net.Mail.MailMessage  
$msg.To.Add($mailaddr)  
#$msg.Bcc.Add($itmag)#抄送给管理员
$msg.From = New-Object System.Net.Mail.MailAddress("it@volcano-force.com","it@volcano-force.com",[system.Text.Encoding]::GetEncoding("UTF-8"))   #发件人
$msg.Subject = "邮件密码即将过期提醒"  
$msg.SubjectEncoding = [system.Text.Encoding]::GetEncoding("UTF-8")  
$msg.Body =$body  
#$Attachments=New-Object System.Net.Mail.Attachment("D:\Documents\xxxx.zip")#创建附件  
#$msg.Attachments.add($Attachments) #添加附件，英文名可多个，中文名就只能带一个。  
$msg.BodyEncoding = [system.Text.Encoding]::GetEncoding("UTF-8")  
$msg.IsBodyHtml = $false#发送html格式邮件  
#$msg.Priority = [System.Net.Mail.MailPriority]::High  
$client = New-Object System.Net.Mail.SmtpClient("smtp.qiye.aliyun.com")  #配置smtp服务器
$client.Port = 25#指定smtp端口
$client.EnableSsl = $false #带ssl功能的smtp服务器
$client.UseDefaultCredentials = $false  
$client.Credentials=New-Object System.Net.NetworkCredential("it@volcano-force.com", "@w!URmb!")  
try {$client.Send($msg)}  
    catch [Exception]
    {$($_.Exception.Message)  
    $mailaddr  
    }
}  


foreach ($user in $alladuser)
{
#用户手机号
$usermobile=Get-ADUser $user -Properties * | %{$_.mobile}
#密码最后一次更改时间
$pwdlastset=Get-ADUser $user -Properties * | %{$_.passwordlastset}
#密码的过期时间
$pwdlastday=$pwdlastset.AddDays(3)
#当前时间
$now=get-date
#判断账户是否设置了永不过期
$neverexpire=get-aduser $user -Properties * |%{$_.PasswordNeverExpires}
#距离密码过期的时间
$expire_days=($pwdlastday - $now).Days
#判断过期时间天小于5天大于-5天（即已过期5天）的并且没有设置密码永不过期的账户
if($expire_days -lt 5 -and $expire_days -gt -5 -and $neverexpire -like "false" )
{
$chineseusername= Get-ADUser $user  -Properties * | %{$_.Displayname}
#邮件正文
$Emailbody=
"Dear $chineseusername :
您的邮箱密码即将在 $expire_days 天后过期，请您尽快更改。
更改密码请遵循以下原则：
○密码长度最少 8 位；
○密码可使用最长时间 90天，过期需要更改密码；
○密码最短使用 1天（ 1 天之内不能再次修改密码）；
○强制密码历史 3个（不能使用之前最近使用的 3 个密码）；
○密码符合复杂性需求（大写字母、小写字母、数字和符号四种中必须有三种、且密码口令中不得包括全部或部分用户名）
"

$tomailaddr = $user + "@volcano-force.com"
#echo $tomailaddr
echo $usermobile
sendmail $tomailaddr $Emailbody
}

}