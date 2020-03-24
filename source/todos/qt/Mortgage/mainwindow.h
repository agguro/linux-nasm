#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QPushButton>
#include <QDoubleValidator>
#include <QIntValidator>
#include "dialog.h"
#include <QtMath>
#include <QDebug>

// Assembly language procedures and functions
extern "C" void mortgage(QString s);

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();
    virtual void closeEvent(QCloseEvent* event);
    void tryFPU();

private:
    Ui::MainWindow* ui;
    Dialog* dg;

private slots:
    void exit();
    void compute();
};
#endif // MAINWINDOW_H
