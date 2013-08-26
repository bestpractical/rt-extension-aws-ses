use inc::Module::Install;

RTx('RT-Extension-AWS-SES');
all_from('lib/RT/Extension/AWS/SES.pm');
readme_from('lib/RT/Extension/AWS/SES.pm');

WriteAll;
