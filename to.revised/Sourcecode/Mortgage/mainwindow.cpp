#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    qDebug() << "setup ui";
    ui->setupUi(this);
    ui->lineEditAnnualRate->setValidator(new QDoubleValidator(0.00,9999999.99,9,this));
    ui->lineEditNumberOfYears->setValidator(new QIntValidator(0,99,this));
    ui->lineEditMortgagePrinciple->setValidator(new QDoubleValidator(0.00,9999999.99,9,this));
    //ui->lineEditMonthlyPayments->setText("12523.23");
    this->setFixedSize(500,345);
    //be sure at least one radiobutton is checked
    ui->radioButtonCND->setChecked(false);
    ui->radioButtonUSA->setChecked(true);
    QObject::connect(ui->pushButtonExit,SIGNAL(clicked()),this,SLOT(exit()));
    QObject::connect(ui->pushButtonCompute,SIGNAL(clicked()),this,SLOT(compute()));
}

MainWindow::~MainWindow()
{
    qDebug() << "deleting ui";
    delete ui;
}

void MainWindow::closeEvent(QCloseEvent *event)
{
    this->dg = new Dialog();
    dg->show();
    qDebug() << "quit application";
    close();
}

void MainWindow::exit()
{
    qDebug() << "exit clicked, closing application";
    close();
}

void MainWindow::compute()
{
    qDebug() << "computing values ...";
    QString mortgagePrinciple = ui->lineEditMortgagePrinciple->text();
    qDebug() << "mortgage principle is " << mortgagePrinciple;
    QString numberOfYears = ui->lineEditNumberOfYears->text();
    qDebug() << "number of years is " << numberOfYears;
    QString annualRate = ui->lineEditAnnualRate->text();
    qDebug() << "annual rate is " << annualRate;
    double flMortgagePrinciple = mortgagePrinciple.toDouble();
    qDebug() << "mortgage principle to float is " << flMortgagePrinciple;
    double flNumberOfYears = numberOfYears.toDouble();
    qDebug() << "number of years to float is " << flNumberOfYears;
    double flAnnualRate = annualRate.toDouble();
    qDebug() << "annual rate to float is " << flAnnualRate;
    //convert Annual Rate to monthly rate
    double flMonthlyRate = 0.0;
    qDebug() << "calculating monthly rate";
    flAnnualRate = flAnnualRate / 100.0;
    if(ui->radioButtonUSA->isChecked())
    {
        //calculation U.S.A.
        qDebug() << "country is U.S.A.";
        flMonthlyRate = flAnnualRate / 12.0;
    }
    else
    {
        if(ui->radioButtonCND->isChecked())
        {
            //calculation Canada
            qDebug() << "country is Canada";
            double flSemiAnnualRate = flAnnualRate / 2.0;
            qDebug() << "semi annual rate = " << flSemiAnnualRate;
            flMonthlyRate = pow((flSemiAnnualRate+1.0),(1.0/6.0))-1.0;
        }
        else
        {
            //severe error, no radiobutton is checked
            qDebug() << "no radiobutton is checked, quiting";
            close();
        }
    }
    qDebug() << "monthly rate = " << flMonthlyRate;
    double flTotalMonths = flNumberOfYears * 12.0;
    qDebug() << "total months = " << flTotalMonths;
    double n = pow((1+flMonthlyRate),flTotalMonths);
    qDebug() << n;

    double flMonthlyPayments = (n/(n-1))*flMonthlyRate*flMortgagePrinciple;
    qDebug() << "Monthly payments" << flMonthlyPayments;
    ui->lineEditMonthlyPayments->setText(QString::number(flMonthlyPayments));
    double flTotalPayment = flMonthlyPayments * flTotalMonths;
    ui->lineEditTotalPayment->setText(QString::number(flTotalPayment));
    tryFPU();
}

void MainWindow::tryFPU()
{
    float n = 65535;
    mortgage(&n);
    qDebug() << n;
}
