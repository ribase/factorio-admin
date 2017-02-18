<?php

namespace Ribase\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Filesystem\Exception\IOExceptionInterface;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Symfony\Component\Serializer\Serializer;
use Symfony\Component\Serializer\Normalizer\ObjectNormalizer;
use Symfony\Component\Form\Extension\Core\Type\SubmitType;
use Ribase\Options\Settings;

class ServeractionController extends Controller
{


    /**
     * @param Request $request
     * @return \Symfony\Component\HttpFoundation\Response
     * @Route("/serveractions", name="Serveractions")
     */
    public function listAction(Request $request)
    {

        $form = $this->createFormBuilder(NULL, array ( 'attr' => array ( 'name' => 'start', 'id' => 'start' ) ) )
            ->add('start', SubmitType::class, array(
                'attr' => array('class' => 'success button', 'value' => 1)
            ))
            ->add('stop', SubmitType::class, array(
                'attr' => array('class' => 'alert button', 'value' => 1)

            ))
            ->add('restart', SubmitType::class, array(
                'attr' => array('class' => 'warning button', 'value' => 1)
            ))
            ->setMethod('POST')
            ->getForm();

        if ($request->isMethod('POST')) {

            $form->submit($request->request->get($form->getName()));

            if ($form->isSubmitted()) {
                $content = $request->request->get('form');
                if(array_key_exists("start",$content)){
                    $result = $this->startServer();
                    if($result == "true"){
                        $this->addFlash(
                            'notice',
                            "server was started"
                        );
                    }else{
                        $this->addFlash(
                            'error',
                            $result
                        );
                    }
                }elseif(array_key_exists("stop",$content)){
                    $result = $this->stopServer();
                    if($result == "true"){
                        $this->addFlash(
                            'notice',
                            "server was stopped"
                        );
                    }else{
                        $this->addFlash(
                            'error',
                            $result
                        );
                    }
                }elseif(array_key_exists("restart",$content)){
                    $result = $this->restartServer();
                    if($result == "true"){
                        $this->addFlash(
                            'notice',
                            "server was restarted"
                        );
                    }else{
                        $this->addFlash(
                            'error',
                            $result
                        );
                    }
                }else{

                }
            }
        }

        return $this->render('admin/serveractions.html.twig', array(
            'form' => $form->createView(),
        ));
    }

    /**
     * @return bool|string
     */
    private function startServer()
    {
        $rootdir = $this->getFactorioDir();
        $factorioPath = $rootdir.'/';

        $pid = shell_exec('pgrep "factorio"');
        sleep(4);

        if(is_null($pid)){
            shell_exec($factorioPath.'start.sh >/dev/null 2>&1');
            return "true";
        }else{
            return "already running with pid ".$pid;
        }
    }

    /**
     * @return bool|string
     */
    private function stopServer()
    {
        $rootdir = $this->getFactorioDir();
        $factorioPath = $rootdir.'/';

        shell_exec($factorioPath.'stop.sh >/dev/null 2>&1');

        sleep(4);

        $pid = shell_exec('pgrep "factorio"');

        if(is_null($pid)){
            return "true";
        }else{
            return "something went wrong, process still running with pid: ".$pid;
        }
    }

    /**
     * @return bool|string
     */
    private function restartServer()
    {
        $pid = shell_exec('pgrep "factorio"');

        $result = $this->stopServer();
        if($result = "true"){
            $result = $this->startServer();
        }else{
            return "something went wrong, process still running with pid: ".$pid;
        }
        if($result = "true"){
            $result = $this->startServer();
        }else{
            return "something went wrong, process not running";
        }

        return $result;
    }

    /**
     * @return int
     */
    private function getRand()
    {
        return rand(1,5);
    }

    private function getFactorioDir()
    {
        $settings = new Settings();

        return $settings->getFactorioDir();
    }


}